require "test_helper"

class LocalizationTest < ActionDispatch::IntegrationTest
  test "интерфейс остаётся английским при другом языке браузера и Native" do
    get new_session_path, headers: { "Accept-Language" => "ru,fr;q=0.9", "User-Agent" => "Hotwire Native Android" }
    assert_response :success
    assert_equal "en", response.headers.fetch("Content-Language")
    assert_select 'html[lang="en"][dir="ltr"]'
    assert_select "h1", text: "Sign in to StarterApp"
    assert_select "input[type=submit][value='Sign in']"
    assert_no_match(/[А-Яа-яЁё]/, response.body)
  end

  test "неподдерживаемая или некорректная locale отклоняется" do
    [ "ru", "fr", "", [ "en" ], { language: "en" } ].each do |locale|
      get new_session_path, params: { locale: locale }
      assert_response :bad_request
      assert_equal :en, I18n.locale
    end
    get new_session_path, params: { locale: "en" }
    assert_response :success
  end

  test "новая локаль применяется к тексту и ссылкам только внутри запроса" do
    previous_backend = I18n.backend
    previous_locales = I18n.available_locales
    catalog = YAML.safe_load_file(Rails.root.join("config/locales/en.yml")).fetch("en")
    I18n.available_locales = %i[en fr]
    I18n.backend = I18n::Backend::Simple.new
    I18n.backend.store_translations(:en, catalog.deep_dup)
    I18n.backend.store_translations(:fr, catalog.deep_merge("sessions" => { "new" => { "heading" => "Connexion à %{app}" } }))

    get new_session_path, params: { locale: "fr" }
    assert_response :success
    assert_select 'html[lang="fr"]'
    assert_select "h1", text: "Connexion à StarterApp"
    assert_select 'a[href="/passwords/new?locale=fr"]'
    assert_equal "fr", response.headers.fetch("Content-Language")
    assert_equal :en, I18n.locale

    get new_session_path
    assert_select "h1", text: "Sign in to StarterApp"
  ensure
    I18n.backend = previous_backend
    I18n.available_locales = previous_locales
  end

  test "письмо и сообщения валидации используют английский словарь" do
    mail = PasswordsMailer.reset(users(:one))
    assert_equal "Reset your StarterApp password", mail.subject
    assert_includes mail.html_part.body.decoded, "Reset password"
    assert_includes mail.text_part.body.decoded, "This link expires in 15 minutes."
    assert_no_match(/[А-Яа-яЁё]/, mail.html_part.body.decoded)
    user = User.new(email_address: "", password: "short", password_confirmation: "different")
    assert_not user.valid?
    assert_includes user.errors.full_messages, "Email can't be blank"
    assert user.errors.full_messages.any? { |message| message.start_with?("Password is too short") }
  end

  test "пропущенный перевод в представлении вызывает исключение" do
    assert_raises(I18n::MissingTranslationData) do
      ApplicationController.helpers.t("missing.translation.for.test")
    end
  end
end
