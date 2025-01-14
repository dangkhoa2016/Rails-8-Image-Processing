url = '...'
response = Faraday.get(url)
image = Vips::Image.new_from_buffer(response.body, '')

puts "image.width: #{image.width}"
puts "image.height: #{image.height}"
puts "image.format: #{image.get('format')}"

image.shrink(1, 2, xshrink: 1)
image.sharpen(x1: 1)
image.resize(0.5)

# ----------------------------
data = {
  shrink: [ 1, 2, { xshrink: 1 } ],
  sharpen: { x1: 1 }
}
data = {
  shrink: [ 0.75, 0.5, { xshrink: 0.25 } ],
  sharpen: { x1: 0.8, sigma: 0.5 }
}

query_string = "sharpen%5Bx1%5D=1&shrink%5B%5D=1&shrink%5B%5D=2&shrink%5B%5D%5Bxshrink%5D=1"
parsed_hash = Rack::Utils.parse_query(query_string)

# ----------------------------
