module Flickr
  class Response
    include Enumerable
    attr_accessor :status, :code, :key, :page, :per_page, :pages, :total, :message
    attr_reader :type, :raw_records, :records
    
    def self.parse(body_string)
      response = new
      json = JSON.parse(body_string) rescue nil
      response.status = json["stat"].to_sym rescue nil
      if response.status && !response.error?
        keys = json.except!("stat").keys
        response.key = keys.first
        response.body = json[response.key]
      elsif response.status
        response.code = json["code"].to_i
        response.message = json["message"]
      end
      response
    end
    
    def error?
      status != :ok
    end
    
    def body=(value)
      self.page = value["page"].to_i
      self.pages = value["pages"].to_i
      self.per_page = value["perpage"].to_i
      self.total = value["total"].to_i
      self.records = value[key.singularize]
    end
    
    def next_page
      page && page < pages ? page + 1 : nil
    end
    
    def last_page
      page && page > 1 ? page - 1 : nil
    end
    
    def key=(value)
      @key = value
      @type = "Flickr::#{key.classify}".constantize rescue nil
    end
    
    def each(&blk)
      if @records.present?
        @records.each(&blk)
      else
        @raw_records.each(&blk)
      end
    end
    
    def to_s
      attributes = []
      if error?
        [:status, :code, :message].each do |key|
          attributes << "#{key}=#{send(key).inspect}"
        end
      else
        [:status, :pages, :page, :per_page, :total, :type, :key].each do |key|
          attributes << "#{key}=#{send(key).inspect}"
        end        
      end
      "#<#{self.class} #{attributes.join(' ')}>"        
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