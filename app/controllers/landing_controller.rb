class LandingController < ApplicationController
  def index
    # Routing handles authenticated users - they go to pages#home automatically
    # This controller only handles unauthenticated visitors
  end
end
