class User < ApplicationRecord
  has_secure_password
  validates :password, length: { minimum: 12 }, allow_nil: true
  has_many :sessions, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def reset_password(password:, password_confirmation:)
    transaction do
      update(password: password, password_confirmation: password_confirmation).tap do |updated|
        Session.revoke_all!(sessions) if updated
      end
    end
  end

  def updates_stream_name
    "user:#{id}:updates"
  end
end
