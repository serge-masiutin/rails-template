class Session < ApplicationRecord
  belongs_to :user

  def self.revoke_all!(scope)
    transaction do
      session_ids = scope.pluck(:id)
      where(id: session_ids).destroy_all
      DisconnectSessionsJob.perform_later(session_ids) if session_ids.any?
    end
  end

  def revoke!
    self.class.revoke_all!(self.class.where(id: id))
  end
end
