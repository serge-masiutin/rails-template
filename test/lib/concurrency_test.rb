require "test_helper"
require "concurrent"

class ConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  class ContextProbeJob < ApplicationJob
    def perform(barrier)
      raise Timeout::Error, "Jobs did not reach the barrier" unless barrier.wait(5)
      [ Current.request_id, Current.session, SemanticLogger.named_tags.slice(:request_id, :job_id) ]
    end
  end

  test "concurrent jobs isolate context and restore caller context" do
    sessions = [ users(:one).sessions.build, users(:two).sessions.build ]
    barrier = Concurrent::CyclicBarrier.new(2)
    # Preload the class so the threads test our contract rather than autoloading.
    jobs = 2.times.map do |index|
      ContextProbeJob.new(barrier).tap { |job| job.request_id = "job-request-#{index}" }
    end
    results = concurrently do |index|
      Rails.application.executor.wrap do
        Current.set(session: sessions.fetch(index), request_id: "outer-#{index}") do
          inside = jobs.fetch(index).perform_now
          [ inside, Current.session, Current.request_id, SemanticLogger.named_tags.dup ]
        end
      end
    end
    results.each_with_index do |(inside, session, request_id, tags), index|
      assert_equal [ "job-request-#{index}", nil, { request_id: "job-request-#{index}", job_id: jobs.fetch(index).job_id } ], inside
      assert_same sessions.fetch(index), session
      assert_equal "outer-#{index}", request_id
      assert_empty tags
    end
  end

  test "unique index protects email against concurrent inserts after validation" do
    email = "concurrency-#{SecureRandom.hex(8)}@example.test"
    digest = users(:one).password_digest
    candidates = 2.times.map { User.new(email_address: email, password_digest: digest) }
    assert candidates.all?(&:valid?)
    barrier = Concurrent::CyclicBarrier.new(2)
    results = concurrently do |index|
      Rails.application.executor.wrap do
        raise Timeout::Error, "Inserts did not reach the barrier" unless barrier.wait(5)
        candidates.fetch(index).save!(validate: false)
        :created
      rescue ActiveRecord::RecordNotUnique
        :duplicate
      end
    end
    assert_equal [ :created, :duplicate ], results.sort
    assert_equal 1, User.where(email_address: email).count
  ensure
    User.where(email_address: email).delete_all if email
  end

  private

  def concurrently
    # Explicit threads serve only to reproduce races deterministically.
    threads = 2.times.map do |index|
      Thread.new { yield index } # rubocop:disable ThreadSafety/NewThread
    end
    ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
      threads.map do |thread|
        raise Timeout::Error, "Test thread did not finish" unless thread.join(10)
        thread.value
      end
    end
  ensure
    threads&.each { |thread| thread.kill if thread.alive? }
    threads&.each(&:join)
  end
end
