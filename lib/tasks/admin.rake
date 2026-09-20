namespace :admin do
  desc "Grant administrator access to an existing user: EMAIL=you@example.com"
  task grant: :environment do
    User.find_by!(email_address: ENV.fetch("EMAIL").strip.downcase).update!(admin: true)
    puts "Administrator access granted"
  end

  desc "Revoke administrator access: EMAIL=you@example.com"
  task revoke: :environment do
    User.find_by!(email_address: ENV.fetch("EMAIL").strip.downcase).update!(admin: false)
    puts "Administrator access revoked"
  end
end
