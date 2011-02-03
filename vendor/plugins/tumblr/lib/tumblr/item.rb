module Tumblr
  class Item
    attr_accessor :id, :slug, :type, :date, :format
    attr_accessor :tags
    
    def self.paginate(params={})
      params[:num] = params[:per_page].to_i > 0 ? params[:per_page].to_i : Tumblr.page_size
      params[:start] = ([params[:page].to_i, 1].max - 1) * params[:num]
      params.delete(:limit)
      params.delete(:page)
      page_xml = xml(params)
      items = parse(page_xml)
      page_meta = page_xml.at("posts")
      if page_meta
        Tumblr::Page.new(items, page_meta["start"], page_meta["total"], params[:num])
      else
        Tumblr::Page.new(items, 0, items.length, params[:num])
      end
    end
    
    def self.all(params={})
      parse(xml(params))
    end
    
    def self.xml(params={})
      Nokogiri::XML(raw(params))
    end
    
    def self.raw(params={})
      fetch_url = url
      fetch_body = params.merge!(:email => Tumblr.email, :password => Tumblr.password).to_query
      Rails.logger.info "tumblr : Fetching url #{fetch_url} with body #{fetch_body}"
      curl = Curl::Easy.http_post(fetch_url, fetch_body)
      curl.body_str
    end

    def self.find(id)
      parse(xml(:id => id.to_i)).first
    end
    
    def to_param
      slug
    end
    
    def date_string
      date.strftime("%B %d, %Y")
    end
    
    def author
      @author ||= tags.find { |t| Tumblr.authors.include?(t.downcase) }
    end
    
    def dom_class
      self.class.to_s.split("::").last.underscore
    end

    private

    def self.url(params={})
      url = "http://#{Tumblr.account}.tumblr.com/api/read"
      url += "?#{params.to_query}" if params.keys.length > 0
      url
    end

    def self.parse(xml)
      xml.css("posts post").collect do |post|
        object_class = "Tumblr::#{post['type'].classify}".constantize rescue nil
        if object_class
          object = object_class.new
          object.send(:parse_xml_node, post)
          object
        end
      end
    end
    
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