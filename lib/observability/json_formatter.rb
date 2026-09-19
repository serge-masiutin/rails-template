module Observability
  class JsonFormatter < SemanticLogger::Formatters::Json
    # Эти поля могут содержать произвольный пользовательский текст и секреты.
    OMITTED_FIELDS = %w[params headers request response path location ip args arguments mail to from cc bcc subject sql binds exception exception_object exception_message].freeze

    def payload
      super
      if hash[:payload].is_a?(Hash)
        hash[:payload] = ActiveSupport::ParameterFilter.new(
          Rails.application.config.filter_parameters + OMITTED_FIELDS.map { |field| /\A#{field}\z/ }
        ).filter(hash[:payload])
      end
    end

    def message
      if log.exception
        hash[:message] = "Ошибка #{log.exception.class.name}"
      else
        super
      end
    end

    def exception
      super
      current = hash[:exception]
      while current
        current.delete(:message)
        current = current[:cause]
      end
    end
  end
end
