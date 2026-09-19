module Images
  # Преобразование выполняет imgproxy; Rails только подписывает URL оригинала на общем диске.
  module VariantUrl
    SUPPORTED_TRANSFORMATIONS = (ImgproxyRails::Transformer::MAP.keys +
      ImgproxyRails::Transformer::PASSTHROUGH_OPTIONS.map(&:to_sym) + %i[format imgproxy_options]).freeze

    def self.call(variant)
      transformations = variant.variation.transformations.deep_dup
      unknown = transformations.keys - SUPPORTED_TRANSFORMATIONS
      raise ArgumentError, "imgproxy не поддерживает преобразования: #{unknown.join(', ')}" if unknown.any?

      # В imgproxy-rails 0.3 format не перенесён, а Transformer изменяет входной hash.
      format = transformations.delete(:format)
      options = ImgproxyRails::Transformer.call(transformations)
      options[:format] ||= format if format
      options[:expires] = 15.minutes.from_now.to_i
      Imgproxy.url_for(source_url(variant.blob), options)
    end

    def self.source_url(blob)
      service = blob.service
      unless service.is_a?(ActiveStorage::Service::DiskService)
        raise ArgumentError, "imgproxy настроен на Disk storage; новый backend требует отдельной настройки источника"
      end
      path = Pathname(service.path_for(blob.key)).relative_path_from(Pathname(service.root))
      raise ArgumentError, "Источник изображения выходит за корень storage" if path.each_filename.include?("..")

      "local:///#{path}"
    end
    private_class_method :source_url
  end
end
