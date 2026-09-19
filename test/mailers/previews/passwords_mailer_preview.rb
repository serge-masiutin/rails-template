class PasswordsMailerPreview < ActionMailer::Preview
  def reset
    # Use an unsaved example account so the preview exposes no real account or usable reset link.
    user = User.new(email_address: "preview@example.test", password: "preview-password")
    PasswordsMailer.reset(user)
  end
end
