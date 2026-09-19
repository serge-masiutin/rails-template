class Ui::NoticeComponentPreview < ViewComponent::Preview
  def notice
    render Ui::NoticeComponent.new(message: I18n.t("components.notice.saved", raise: true))
  end

  def alert
    render Ui::NoticeComponent.new(message: I18n.t("components.notice.invalid", raise: true), variant: :alert)
  end
end
