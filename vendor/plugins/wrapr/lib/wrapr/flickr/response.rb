module Wrapr
  module Flickr
    class Response < Wrapr::Response
      include Enumerable

      content_type Mime::JSON
      jsonp_fn 'jsonFlickrApi'

      attr_accessor :code, :key, :page, :per_page, :pages, :total
      attr_reader :type, :raw_records, :records
      
      def parse_response(parsed)
        self.status = parsed["stat"].to_sym rescue nil
        if status && success?
          self.key = parsed.except!("stat").keys.first
          self.page = parsed[key]["page"].to_i
          self.pages = parsed[key]["pages"].to_i
          self.per_page = parsed[key]["perpage"].to_i
          self.total = parsed[key]["total"].to_i
          self.records = parsed[key][key.singularize]
        elsif status
          self.code = parsed['code'].to_i
          self.error_message = parsed['message']
        end
      end
    
      def status=(value)
        case value
        when :ok
          @status = 200
        when :fail
          @status = 500
        end
      end
            
      def next_page
        page && page < pages ? page + 1 : nil
      end
    
      def last_page
        page && page > 1 ? page - 1 : nil
      end
    
      def key=(value)
        @key = value
        @type = "Wrapr::Flickr::#{key.classify}".constantize rescue nil
      end
    
      def each(&blk)
        if @records.present?
          @records.each(&blk)
        elsif @raw_records.present?
          @raw_records.each(&blk)
        else
          [].each(&blk)
        end
      end
    
      private
    
      def records=(value)
        @raw_records = []
        @records = []
        if value && value.respond_to?(:each)
          value.each do |record|
            @raw_records << record
            @records << @type.parse(record) if @type && @type.respond_to?(:parse)
          end
        end
      end
    end
  end
end