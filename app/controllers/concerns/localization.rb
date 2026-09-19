module Localization
  extend ActiveSupport::Concern

  included do
    prepend_around_action :with_request_locale
  end

  def default_url_options
    super.merge(I18n.locale == I18n.default_locale ? {} : { locale: I18n.locale })
  end

  private

  def with_request_locale(&action)
    locale = params.fetch(:locale, I18n.default_locale.to_s)
    unless locale.is_a?(String) && I18n.available_locales.map(&:to_s).include?(locale)
      raise ActionController::BadRequest, "Unsupported locale"
    end

    I18n.with_locale(locale) do
      response.set_header("Content-Language", I18n.locale.to_s)
      action.call
    end
  end
end
