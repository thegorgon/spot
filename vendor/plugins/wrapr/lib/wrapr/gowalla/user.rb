module Wrapr
  module Gowalla
    class User < Wrapr::Model
      property :id, :image_url, :last_name, :first_name
      
      def full_name
        "#{first_name} #{last_name}"
      end
      
      def url=(value)
        self.id = value.gsub(/\/users\/(\d+)/i, '\1')
      end
    end
  end
end