require "application_system_test_case"

class TypographyTest < ApplicationSystemTestCase
  teardown do
    page.driver.headers = {}
    page.current_window.resize_to(1280, 900)
  end

  test "веб-форма загружает Martian Mono и помещается на узком экране" do
    page.current_window.resize_to(390, 844)
    visit new_session_path
    assert_text "Войти в StarterApp"
    assert_martian_mono
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
    page.save_screenshot(Rails.root.join("tmp/screenshots/martian-mono-mobile.png"))
  end

  test "служебные панели используют тот же локальный шрифт" do
    previous = Rails.configuration.x.operations
    Rails.configuration.x.operations = OperationsConfig.new(username: "operator", password: "p" * 32)
    page.driver.add_headers("Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("operator", "p" * 32))

    visit operations_agents_path
    assert_text "Трассы агентов"
    assert_martian_mono
    visit "/ops/jobs"
    assert_selector "body .container"
    assert_martian_mono
  ensure
    Rails.configuration.x.operations = previous
  end

  private

  def assert_martian_mono
    loaded = page.evaluate_async_script(<<~JS)
      const done = arguments[0];
      document.fonts.ready.then(() => done(
        [...document.fonts].some(font => font.family === "Martian Mono" && font.status === "loaded")
      ));
    JS
    assert loaded, "Браузер должен загрузить локальный Martian Mono"

    other_fonts = page.evaluate_script(<<~JS)
      [...document.body.querySelectorAll("*")]
        .filter(element => element.getClientRects().length &&
          [...element.childNodes].some(node => node.nodeType === Node.TEXT_NODE && node.textContent.trim()))
        .map(element => getComputedStyle(element).fontFamily)
        .filter(family => !family.startsWith('"Martian Mono"'));
    JS
    assert_empty other_fonts.uniq, "Видимый текст должен использовать единое семейство"
    assert_equal '"Martian Mono", monospace', page.evaluate_script('getComputedStyle(document.querySelector("button, input, a")).fontFamily')
  end
end
