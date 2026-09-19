require "test_helper"

class TransactionSafetyTest < ActiveSupport::TestCase
  # Exercise real commit/rollback without an outer fixture transaction.
  self.use_transactional_tests = false

  setup do
    stub_request(:get, "https://example.test/transaction-probe").to_return(status: 200)
  end

  test "Isolator rejects HTTP inside a transaction" do
    assert_raises(Isolator::HTTPError) do
      User.transaction do
        User.count
        Net::HTTP.get(URI("https://example.test/transaction-probe"))
      end
    end
  end
end
