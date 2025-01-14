url = '...'
response = Faraday.get(url)
image = Magick::Image.from_blob(response.body).first

image.resize(100, 100)
image.spread(5)
