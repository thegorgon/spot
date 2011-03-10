module Wrapr
  module Yelp
    class Review < Wrapr::Model
      property :id, :rating, :rating_img_url, :rating_img_url_small, :time_created, :excerpt
      property :user, :model => User
    end
  end
end