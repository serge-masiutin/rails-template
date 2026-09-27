class Ui::SubmitComponent < ApplicationComponent
  def initialize(form:, label:, disabled: false, submitting_label: nil)
    @form = form
    @label = label
    @disabled = disabled
    @submitting_label = submitting_label
  end
end
