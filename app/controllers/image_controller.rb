# example:

# {
#   shrink: [5, 5, { xshrink: 50 }],
#   sharpen: { x1: 0.8, sigma: 0.5 }
# }
# /image?url=https://.....png&sharpen[sigma]=0.5&sharpen[x1]=0.8&shrink[]=5&shrink[]=5&shrink[][xshrink]=50

# {
#   "sharpen": {
#     "radius": 100,
#     "x1": 0.1
#   },
# }
# /image?url=https://.....png&sharpen[x1]=0.1&sharpen[radius]=100

# {
#   "resize": [
#     0.3
#   ]
# }
# /image?url=https://.....png&resize[]=0.3
# /image?url=https://.....png&resize[]=2

# {
#   "shrink": [
#     2
#   ]
# }
# /image?url=https://.....png&shrinkh[]=2

class ImageController < ApplicationController
  # GET /index
  def index
    # Get image URL from query string
    url = request.query_parameters.delete(:url)
    if url.blank?
      url = request.query_parameters.delete(:u)
    end

    # Check if the URL is present
    if url.blank?
      render json: { error: I18n.translate("errors.url_parameter_is_required") }, status: :bad_request
      return
    end

    # Check if the URL is valid
    unless url =~ URI::DEFAULT_PARSER.make_regexp
      render json: { error: I18n.translate("errors.invalid_url") }, status: :bad_request
      return
    end

    # Download the image from the URL
    begin
      response = Faraday.get(url)  # Download the image from the URL
      image = Magick::Image.from_blob(response.body).first  # Create an image object from the buffer

      # Loop through query string parameters and apply corresponding operations
      image = apply_image_transformations(image, request.query_parameters)

      # Save the processed image to memory (no file required)
      image_format = request.query_parameters["format"] # Get the image format from the query string
      unless image_format.present?
        image_format = response.headers["content-type"].split("/").last || "jpg" # Get the image format from the content-type header
      end

      image.format = image_format

      # Return the image as binary data (image/jpeg)
      send_data image.to_blob, type: "image/#{image_format}", disposition: "inline"

    rescue => e
      render json: { error: I18n.translate("errors.failed_to_process_image", message: e.message) }, status: :unprocessable_entity
    end
  end

  private

  def get_hash_from_query_string(query_string)
    Rack::Utils.parse_nested_query(query_string) rescue {}
  end

  def convert_params_value_string_to_number(param)
    if param.is_a?(Hash)
      param.each do |key, value|
        param[key] = convert_params_value_string_to_number(value)
      end
      return param
    end

    if param.is_a?(Array)
      return param.map { |value| convert_params_value_string_to_number(value) }
    end

    if param.to_i.to_s == param
      param.to_i
    elsif param.to_f.to_s == param
      param.to_f
    else
      param
    end
  end

  # Apply image transformations based on query string parameters
  # example: /images?sharpen[x1]=1&shrink[]=1&shrink[]=2&shrink[][xshrink]=1
  # {"sharpen"=>{"x1"=>"1"}, "shrink"=>["1", "2", {"xshrink"=>"1"}]}
  def apply_image_transformations(image, tranform_methods = {})
    puts "apply_image_transformations: #{tranform_methods}"
    tranform_methods.each do |method, params|
      if image.respond_to?(method) && image.method(method).parameters.any?
        puts "applying #{method} with params #{params}"

        begin
          if params.is_a?(Array)
            params = convert_params_value_string_to_number(params)
            # find the first hash in the array
            hash_params = params.find { |p| p.is_a?(Hash) } || {}
            rest_params = params - [ hash_params ]
            image = image.send(method, *rest_params, **hash_params)
          elsif params.is_a?(Hash)
            image = image.send(method, **convert_params_value_string_to_number(params))
          else
            image = image.send(method, convert_params_value_string_to_number(params))
          end
        rescue => e
          puts "Error applying #{method} with params #{params}: #{e.message}"
        end
      end
    end

    image
  end
end
