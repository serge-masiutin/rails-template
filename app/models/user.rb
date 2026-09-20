class User < ApplicationRecord
  has_secure_password
  validates :password, length: { minimum: 12 }, allow_nil: true
  has_many :sessions, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  after_update_commit -> { Realtime::OperationsUpdates.access_changed(id) }, if: :saved_change_to_admin?

  def self.authenticate_session(email_address:, password:, user_agent:, ip_address:)
    user = authenticate_by(email_address: email_address, password: password)
    return unless user

    user.with_lock do
      # Password reset may have committed since authenticate_by loaded the digest.
      return unless user.authenticate(password)

      user.sessions.create!(user_agent: user_agent, ip_address: ip_address)
    end
  end

  def self.reset_password(token:, password:, password_confirmation:)
    user = find_by_password_reset_token!(token)
    user.with_lock do
      # A concurrent reset can invalidate the token after the initial lookup.
      find_by_password_reset_token!(token)
      user.sessions.revoke_all if user.update(password: password, password_confirmation: password_confirmation)
    end
    user
  end

  def updates_stream_name
    "user:#{id}:updates"
  end
end
