class Session < ApplicationRecord
  belongs_to :user

  def self.revoke_all
    transaction do
      session_ids = pluck(:id)
      where(id: session_ids).destroy_all
      if session_ids.any?
        intent = SessionDisconnect.create!(session_ids: session_ids)
        AfterCommitEverywhere.after_commit(without_tx: :raise) { intent.enqueue }
      end
    end
  end

  def revoke
    self.class.where(id: id).revoke_all
  end
end
