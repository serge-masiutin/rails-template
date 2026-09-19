require "test_helper"
require "concurrent"

class ConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  class ContextProbeJob < ApplicationJob
    def perform(barrier)
      raise Timeout::Error, "Задания не достигли барьера" unless barrier.wait(5)
      [ Current.request_id, Current.session, SemanticLogger.named_tags.slice(:request_id, :job_id) ]
    end
  end

  test "одновременные задания изолируют контекст и возвращают вызывающий контекст" do
    sessions = [ users(:one).sessions.build, users(:two).sessions.build ]
    barrier = Concurrent::CyclicBarrier.new(2)
    # Предзагрузка класса до потоков исключает проверку autoload вместо нашего контракта.
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

  test "Executor очищает Current после ошибки и возвращает соединение в пул" do
    pool = ApplicationRecord.connection_pool
    results = concurrently do |index|
      begin
        Rails.application.executor.wrap do
          Current.request_id = "failed-#{index}"
          pool.lease_connection
          raise ArgumentError, "Проверка cleanup"
        end
      rescue ArgumentError
        [ Current.request_id, Current.session, pool.active_connection? ]
      end
    end
    assert_equal [ [ nil, nil, nil ], [ nil, nil, nil ] ], results
  end

  test "уникальный индекс защищает email при конкурентной вставке после валидации" do
    email = "concurrency-#{SecureRandom.hex(8)}@example.test"
    digest = users(:one).password_digest
    candidates = 2.times.map { User.new(email_address: email, password_digest: digest) }
    assert candidates.all?(&:valid?)
    barrier = Concurrent::CyclicBarrier.new(2)
    results = concurrently do |index|
      Rails.application.executor.wrap do
        raise Timeout::Error, "Вставки не достигли барьера" unless barrier.wait(5)
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
    # Явные потоки нужны только для воспроизводимой проверки гонок.
    threads = 2.times.map do |index|
      Thread.new { yield index } # rubocop:disable ThreadSafety/NewThread
    end
    ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
      threads.map do |thread|
        raise Timeout::Error, "Поток теста не завершился" unless thread.join(10)
        thread.value
      end
    end
  ensure
    threads&.each { |thread| thread.kill if thread.alive? }
    threads&.each(&:join)
  end
end
