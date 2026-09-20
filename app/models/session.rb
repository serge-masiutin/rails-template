class Session < ApplicationRecord
  belongs_to :user

  def self.revoke_all
    transaction do
      session_ids = pluck(:id)
      where(id: session_ids).destroy_all
      DisconnectSessionsJob.perform_later(session_ids) if session_ids.any?
    end
  end

  def revoke
    self.class.where(id: id).revoke_all
  end
end
