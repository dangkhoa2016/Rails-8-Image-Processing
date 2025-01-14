class ImageTransformHelper
  class << self
    def get_transform_params(response_headers, transform_methods, current_size)
      bg = determine_background_color(transform_methods)
      image_format = determine_image_format(transform_methods)

      result_format = determine_result_format(response_headers, image_format)

      apply_image_format(transform_methods, image_format, result_format)

      apply_flatten_if_required(transform_methods, result_format, bg) if image_format.present?

      transform_methods.delete(:image)
      puts "get_transform_params: #{transform_methods}"

      if transform_methods.key?(:rotate)
        flatten = transform_methods.delete(:flatten)
        rotate = transform_methods.delete(:rotate)
        unless flatten.present?
          flatten = { background: white_background }
        end
        transform_methods[:flatten] = flatten
        transform_methods[:rotate] = modify_rotation(rotate)
      end

      if transform_methods.key?(:resize)
        resize = transform_methods.delete(:resize)
        transform_methods[:resize] = modify_resize(resize, current_size)
      end

      transform_methods
    end

    private

    def white_background
      [ 255, 255, 255 ]
    end

    def convert_color(color)
      return color if color.is_a?(Array)

      parsed_color = ColorConversion::Color.new(color) rescue nil

      if parsed_color.present?
        parsed_color.rgb.values
      else
        white_background
      end
    end

    def modify_resize(resize, current_size)
      return 0 unless resize

      if resize.is_a?(Array)
        scale, options = resize
        [ scale, options || {} ]
      elsif resize.is_a?(Hash)
        width = resize[:width]
        height = resize[:height]
        scale = resize[:scale]
        options = resize.except(:width, :height, :scale)
        # calculate the scale if only one dimension is provided
        if width
          scale = width.to_f / current_size[0]
          [ scale, options || {} ]
        elsif height
          scale = height.to_f / current_size[1]
          [ scale, options || {} ]
        elsif scale
          [ scale, options || {} ]
        end
      else
        resize
      end
    end

    def modify_rotation(rotation)
      return 0 unless rotation

      if rotation.is_a?(Array)
        angle, options = rotation
        bg = options && (options[:bg] || options[:background])
        bg ||= white_background # white background instead of black
        [ angle, { background: convert_color(bg) } ]
      elsif rotation.is_a?(Hash)
        angle = rotation[:angle]
        bg = rotation[:bg] || rotation[:background]
        [ angle, { background: convert_color(bg) } ]
      else
        [ rotation, { background: white_background } ]
      end
    end

    def determine_background_color(transform_methods)
      bg = transform_methods.delete(:bg) || transform_methods.delete(:background) || white_background
      convert_color(bg)
    end

    def determine_image_format(transform_methods)
      transform_methods.delete(:format) ||
        transform_methods.delete(:f) ||
        transform_methods.delete(:toFormat)
    end

    def determine_result_format(response_headers, image_format)
      result_format = response_headers["content-type"].split("/").last || "jpg"

      if image_format.present?
        if image_format.is_a?(String)
          result_format = image_format.downcase
        elsif image_format.is_a?(Array)
          first = image_format.first
          if first.is_a?(String)
            result_format = first.downcase
          elsif first.is_a?(Hash)
            result_format = first[:format].downcase if first[:format].present?
          end
        elsif image_format.is_a?(Hash)
          result_format = image_format[:format].downcase if image_format[:format].present?
        end
      end
      result_format
    end

    def apply_image_format(transform_methods, image_format, result_format)
      return unless image_format.present?

      transform_methods[:image_format] = { format: result_format }

      case image_format
      when String
        transform_methods[:image_format][:format] = result_format
      when Array
        handle_array_image_format(transform_methods, image_format)
      when Hash
        handle_hash_image_format(transform_methods, image_format)
      end
    end

    def handle_array_image_format(transform_methods, image_format)
      if image_format.size == 1
        first = image_format.first
        if first.is_a?(String)
          result_format = first.downcase
        elsif first.is_a?(Hash)
          apply_hash_image_format_fields(transform_methods, first)
        end
      end

      if image_format.size == 2 && image_format[1].present?
        transform_methods[:quality] = image_format[1]
      end
    end

    def handle_hash_image_format(transform_methods, image_format)
      apply_hash_image_format_fields(transform_methods, image_format)
    end

    def apply_hash_image_format_fields(transform_methods, image_format)
      result_format = image_format[:format]&.downcase
      transform_methods[:image_format][:format] = result_format if result_format

      if image_format[:quality].present?
        transform_methods[:quality] = image_format[:quality]
      end
    end

    def apply_flatten_if_required(transform_methods, result_format, bg)
      if transform_methods[:flatten].blank? && [ "jpeg", "jpg" ].include?(result_format)
        transform_methods[:flatten] = { background: bg }
      end
    end
  end
end
