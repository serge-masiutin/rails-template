class PasswordsMailerPreview < ActionMailer::Preview
  def reset
    # Use a synthetic account and an unusable reset token in previews.
    user = User.new(email_address: "preview@example.test", password: "preview-password")
    PasswordsMailer.reset(user)
  end
end
