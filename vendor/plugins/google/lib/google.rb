module Google
  class << self
    def options
      @options ||= {}
    end
    
    def options=(value)
      @options.merge!(value)
    end
    
    def load_config!
      file = options[:config_file] || File.join(Rails.root, 'config', 'apis', 'google.yml')
      yaml = YAML.load_file(file) rescue nil
      if yaml && yaml["google"]
        @config = yaml["google"].symbolize_keys!
      else
        raise LoadError, "Cannot find Google Configuration in Path : #{file}"
      end
    end
  
    def config
      load_config! if @config.nil?
      @config
    end
  
    def api_key(host_with_port)
      config[:api_keys][host_with_port]
    end
  end
end