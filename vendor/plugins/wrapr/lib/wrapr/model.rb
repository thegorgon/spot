module Wrapr
  class Model
    def self.acts_as_model(*args)
      options = args.extract_options!
      @attrs = args
      attr_accessor(*@attrs)
    end
    
    def self.parse(json)
      object = new
      json ||= {}
      json.each do |key, value|
        key = key.underscore
        object.send("#{key}=", value) if object.respond_to?("#{key}=")
      end
      object
    end
    
    def initialize(params={})
      params.each do |key, value|
        if respond_to?("#{key}=")
          send("#{key}=", value)
        end
      end
    end
  end
end