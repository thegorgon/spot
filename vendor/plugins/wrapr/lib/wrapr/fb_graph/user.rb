module Wrapr
  module FbGraph
    class User < Wrapr::Model
      property :name, :first_name, :last_name, :gender, :locale, :link, 
                :timezone, :updated_time, :verified, :about, :bio, :birthday,
                :email, :interested_in, :meeting_for, :political,
                :quotes, :relationship_status, :religion, :website
      
      property :id, :method => :to_i
      
      def self.find(id, options={})
        response = FbGraph::Request.get("/#{id}", {}, options)
        if response.success?
          self.parse(response.payload)
        else
          nil
        end
      end
    end
  end
end