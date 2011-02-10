module Flickr
  class << self
    def options
      @options ||= {}
    end
    
    def options=(value)
      @options = value
    end
  
    def load_config!
      file = options[:config_file] || File.join(Rails.root, 'config', 'apis', 'flickr.yml')
      yaml = YAML.load_file(file) rescue nil
      if yaml && yaml["flickr"]
        @config = yaml["flickr"].symbolize_keys!
      else
        raise LoadError, "Cannot find Flickr Configuration in Path : #{file}"
      end
    end
  
    def config
      load_config! if @config.nil?
      @config
    end
    
    def api_key
      config[:key]
    end
    
    def api_secret
      config[:secret]
    end
  end
end