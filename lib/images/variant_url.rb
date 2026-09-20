module Images
  module VariantUrl
    SUPPORTED_TRANSFORMATIONS = (ImgproxyRails::Transformer::MAP.keys +
      ImgproxyRails::Transformer::PASSTHROUGH_OPTIONS.map(&:to_sym) + %i[format imgproxy_options]).freeze

    def self.call(variant)
      transformations = variant.variation.transformations.deep_dup
      unknown = transformations.keys - SUPPORTED_TRANSFORMATIONS
      raise ArgumentError, "imgproxy does not support transformations: #{unknown.join(', ')}" if unknown.any?

      # imgproxy-rails 0.3 omits format and mutates the transformation hash.
      format = transformations.delete(:format)
      options = ImgproxyRails::Transformer.call(transformations)
      options[:format] ||= format if format
      options[:expires] = 15.minutes.from_now.to_i
      Imgproxy.url_for(source_url(variant.blob), options)
    end

    def self.source_url(blob)
      service = blob.service
      unless service.is_a?(ActiveStorage::Service::DiskService)
        raise ArgumentError, "imgproxy requires Disk storage; configure its source before using another backend"
      end
      path = Pathname(service.path_for(blob.key)).relative_path_from(Pathname(service.root))
      raise ArgumentError, "Image source escapes the storage root" if path.each_filename.include?("..")

      "local:///#{path}"
    end
    private_class_method :source_url
  end
end
