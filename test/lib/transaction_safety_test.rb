require "test_helper"

class TransactionSafetyTest < ActiveSupport::TestCase
  # Exercise real commit/rollback without an outer fixture transaction.
  self.use_transactional_tests = false

  setup do
    @request = stub_request(:get, "https://example.test/transaction-probe").to_return(status: 200)
  end

  test "Isolator rejects HTTP inside a transaction" do
    assert_raises(Isolator::HTTPError) do
      User.transaction do
        User.count
        Net::HTTP.get(URI("https://example.test/transaction-probe"))
      end
    end
  end

  test "callback runs only after the outer commit" do
    User.transaction do
      User.count
      User.transaction(requires_new: true) { register_request }
      assert_not_requested @request
    end
    assert_requested @request, times: 1
  end

  test "rollback cancels the callback" do
    User.transaction do
      User.count
      register_request
      raise ActiveRecord::Rollback
    end
    assert_not_requested @request
  end

  test "strict callback requires an open transaction" do
    assert_raises(AfterCommitEverywhere::NotInTransaction) { register_request }
    assert_not_requested @request
  end

  private

  def register_request
    AfterCommitEverywhere.after_commit(without_tx: :raise) do
      Net::HTTP.get(URI("https://example.test/transaction-probe"))
    end
  end
end
