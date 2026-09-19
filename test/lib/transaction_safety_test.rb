require "test_helper"

class TransactionSafetyTest < ActiveSupport::TestCase
  # Проверяем настоящий commit/rollback, без внешней транзакции fixtures.
  self.use_transactional_tests = false

  setup do
    @request = stub_request(:get, "https://example.test/transaction-probe").to_return(status: 200)
  end

  test "Isolator запрещает HTTP внутри транзакции" do
    assert_raises(Isolator::HTTPError) do
      User.transaction do
        User.count
        Net::HTTP.get(URI("https://example.test/transaction-probe"))
      end
    end
  end

  test "callback выполняется только после внешнего commit" do
    User.transaction do
      User.count
      User.transaction(requires_new: true) { register_request }
      assert_not_requested @request
    end
    assert_requested @request, times: 1
  end

  test "rollback отменяет callback" do
    User.transaction do
      User.count
      register_request
      raise ActiveRecord::Rollback
    end
    assert_not_requested @request
  end

  test "строгий callback требует открытую транзакцию" do
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
