module Wrapr
  class Model
    
    def self.property(*args)
      options = args.extract_options!
      @_attr_map ||= {}
      args.each do |arg|
        @_attr_map[(options[:as] || arg).to_sym] = arg
        define_method "#{arg}=" do |value|
          if options[:list] && options[:model] && value.kind_of?(Enumerable)
            value = value.collect { |value| options[:model].parse(value) }
          elsif options[:model]
            value = options[:model].parse(value) if options[:model]
          end
          instance_variable_set "@#{arg}", value
        end
        define_method "#{arg}" do
          instance_variable_get "@#{arg}"
        end
        if options[:in]
          define_method "#{options[:in]}=" do value
            args.each do |key|
              send("#{key}=", value[key.to_s])
            end
          end
        end
      end
    end
    
    def self.parse(json)
      object = new
      json ||= {}
      json.each do |key, value|
        key = key.underscore.to_sym
        key = @_attr_map[key] if @_attr_map.has_key?(key)
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