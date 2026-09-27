class Ui::FieldComponent < ApplicationComponent
  INPUT_HELPERS = { email: :email_field, password: :password_field }.freeze

  def initialize(form:, attribute:, label:, type:, required: false, autofocus: false,
    autocomplete: nil, value: nil, minlength: nil, maxlength: nil, hint: nil, error: nil)
    @form = form
    @attribute = attribute
    @label = label
    @input_helper = INPUT_HELPERS.fetch(type)
    @hint = hint
    @error = error.presence
    @id = form.field_id(attribute)
    @input_options = {
      id: @id, required: required, autofocus: autofocus, autocomplete: autocomplete,
      minlength: minlength, maxlength: maxlength,
      class: "w-full rounded-xl border border-line bg-surface px-4 py-3",
      aria: { invalid: @error ? true : nil,
        describedby: [ ("#{@id}-hint" if @hint), ("#{@id}-error" if @error) ].compact.presence&.join(" ") }
    }
    @input_options[:value] = value if type == :email && !value.nil?
  end
end
