class Ui::NoticeComponentPreview < ViewComponent::Preview
  def notice
    render Ui::NoticeComponent.new(message: "Изменения сохранены.")
  end

  def alert
    render Ui::NoticeComponent.new(message: "Проверьте введённые значения.", variant: :alert)
  end
end
