module Tumblr
  class << self
    def options
      @options ||= {}
    end
    
    def options=(value)
      @options = value
    end
  
    def config
      @config ||= YAML.load_file(@options[:config_file] || File.join(Rails.root, 'config', 'tumblr.yml'))["tumblr"].symbolize_keys!
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
      @page_size ||= @options[:page_size] ? @options[:page_size].to_i : 20
    end
  end
end