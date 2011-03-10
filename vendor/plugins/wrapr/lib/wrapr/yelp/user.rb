module Wrapr
  module Yelp
    class User < Wrapr::Model
      property :id, :image_url, :name
    end
  end
end