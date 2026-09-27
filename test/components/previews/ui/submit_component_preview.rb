class Ui::SubmitComponentPreview < ViewComponent::Preview
  def ready
    render_with_template(template: "ui/submit_component_preview/form", locals: { disabled: false })
  end

  def disabled
    render_with_template(template: "ui/submit_component_preview/form", locals: { disabled: true })
  end
end
