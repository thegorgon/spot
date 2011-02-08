module Tumblr
  class << self
    def options
      @options ||= {}
    end
    
    def options=(value)
      @options.merge!(value)
    end
    
    def load_config!
      file = options[:config_file] || File.join(Rails.root, 'config', 'tumblr.yml')
      yaml = YAML.load_file(file) rescue nil
      if yaml && yaml["tumblr"]
        @config = yaml["tumblr"].symbolize_keys!
      else
        raise LoadError, "Cannot find Tumblr Configuration in Path : #{file}"
      end
    end
  
    def config
      load_config! if @config.nil?
      @config
    end
  
    def authors
      config[:authors] || []
    end

    def account
      config[:account]
    end
  
    def email
      config[:email]
    end
  
    def password
      config[:password]
    end
  
    def page_size
      @page_size ||= config[:page_size] ? config[:page_size].to_i : 20
    end
  end
end