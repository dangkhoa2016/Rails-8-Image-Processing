class HomeController < ApplicationController
  def index
    render json: { message: "Welcome to Rails 8 Image Processing API" }
  end
end
