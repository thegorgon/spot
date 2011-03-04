module Wrapr
  class Config
    
    def self.init(name)
      config = yaml[name]
      new(config)
    end
    
    def self.yaml
      @yaml ||= YAML.load_file(options[:config_file] || File.join(Rails.root, 'config', 'apis', 'wrapr.yml'))
      @yaml['wrapr']
    end

    def self.options
      @options ||= {}
    end
    
    def self.options=(value)
      @options = value
    end
    
    def initialize(config)
      @config = config
    end
    
    def [](key)
      @config[key.to_s]
    end
    
    def method_missing(method, *args, &block)
      if @config[method.to_s]
        @config[method.to_s]
      else
        raise NoMethodError, "Undefined method #{method} for #{self.class}"
      end
    end
  end
end