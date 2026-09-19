namespace :admin do
  desc "Выдать существующему пользователю доступ в админку: EMAIL=you@example.com"
  task grant: :environment do
    User.find_by!(email_address: ENV.fetch("EMAIL").strip.downcase).update!(admin: true)
    puts "Доступ администратора выдан"
  end

  desc "Отозвать доступ в админку: EMAIL=you@example.com"
  task revoke: :environment do
    User.find_by!(email_address: ENV.fetch("EMAIL").strip.downcase).update!(admin: false)
    puts "Доступ администратора отозван"
  end
end
