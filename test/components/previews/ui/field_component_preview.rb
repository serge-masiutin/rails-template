class Ui::FieldComponentPreview < ViewComponent::Preview
  def email
    field(attribute: :email_address, label: I18n.t("fields.email"), type: :email,
      autocomplete: "username", hint: I18n.t("components.field.email_hint"))
  end

  def password
    field(attribute: :password, label: I18n.t("fields.password"), type: :password,
      autocomplete: "new-password", minlength: 12, maxlength: 72)
  end

  def invalid_password
    field(attribute: :password, label: I18n.t("fields.password"), type: :password,
      autocomplete: "new-password", minlength: 12, maxlength: 72,
      error: I18n.t("components.field.password_error"))
  end

  private
    def field(**options)
      render_with_template(template: "ui/field_component_preview/form", locals: { field_options: options })
    end
end
