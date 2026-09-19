module Images
  # imgproxy transforms images; Rails signs source URLs on shared storage.
  module VariantUrl
    SUPPORTED_TRANSFORMATIONS = (ImgproxyRails::Transformer::MAP.keys +
      ImgproxyRails::Transformer::PASSTHROUGH_OPTIONS.map(&:to_sym) + %i[format imgproxy_options]).freeze

    def self.call(variant)
      transformations = variant.variation.transformations.deep_dup
      unknown = transformations.keys - SUPPORTED_TRANSFORMATIONS
      raise ArgumentError, "imgproxy does not support transformations: #{unknown.join(', ')}" if unknown.any?

      # imgproxy-rails 0.3 omits format and Transformer mutates its input hash.
      format = transformations.delete(:format)
      options = ImgproxyRails::Transformer.call(transformations)
      options[:format] ||= format if format
      options[:expires] = 15.minutes.from_now.to_i
      Imgproxy.url_for(source_url(variant.blob), options)
    end

    def self.source_url(blob)
      service = blob.service
      unless service.is_a?(ActiveStorage::Service::DiskService)
        raise ArgumentError, "imgproxy uses Disk storage; another backend requires explicit source configuration"
      end
      path = Pathname(service.path_for(blob.key)).relative_path_from(Pathname(service.root))
      raise ArgumentError, "Image source escapes the storage root" if path.each_filename.include?("..")

      "local:///#{path}"
    end
    private_class_method :source_url
  end
end
