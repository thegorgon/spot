module Wrapr
  module Tumblr
    class Item
      attr_accessor :id, :slug, :type, :date, :format
      attr_accessor :tags
      PAGE_SIZE = 5
    
      def self.paginate(params={})
        params[:num] = params[:per_page].to_i > 0 ? params[:per_page].to_i : (Tumblr.config[:page_size] || PAGE_SIZE)
        params[:start] = ([params[:page].to_i, 1].max - 1) * params[:num]
        params.delete(:limit)
        params.delete(:page)
        response = Tumblr::Request.post("/api/read", params)
        response.page_size = params[:num].to_i unless response.frozen?
        response
      end
    
      def self.all(params={})
        Tumblr::Request.post("/api/read", {}, :cache => true)
      end
        
      def self.find(id)
        Tumblr::Request.post("/api/read", { :id => id.to_i }, :cache => true).first
      end
    
      def to_param
        slug
      end
    
      def date_string
        date.strftime("%B %d, %Y")
      end
    
      def author
        @author ||= tags.find { |t| Tumblr.config.authors.include?(t.downcase) }
      end
          
      def dom_class
        self.class.to_s.split("::").last.underscore
      end
      
      private
    
      def parse_xml_node(node)
        self.id = node['id']
        self.slug = node['slug']
        self.date = Time.at(node['unix-timestamp'].to_i)
        self.format = node['format']
        self.tags = node.css("tag").collect do |tag|
          tag.content
        end
        self
      end
    end
  end
end