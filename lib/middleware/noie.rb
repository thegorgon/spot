module Rack
  class NoIE
    def initialize(app, options = {})
      @app = app
      @options = options
      @options[:redirect] ||= 'http://www.microsoft.com/windows/internet-explorer/default.aspx'
      @options[:minimum] ||= 7.0
    end

    def call(env)
      if ie_found_in?(env) && !on_redirect_page?(env)
        kick_it
      else
        @app.call(env)
      end
    end

    private

    def ie_found_in?(env)
      if env['HTTP_USER_AGENT']
        is_ie?(env['HTTP_USER_AGENT']) && ie_version(env['HTTP_USER_AGENT']) < @options[:minimum]
      end
    end
    
    def on_redirect_page?(env)
      @options[:redirect] != env['PATH_INFO']
    end
    
    def is_ie?(ua_string)
      # We need at least one digit to be able to get the version, hence the \d
      ua_string.match(/MSIE \d/) ? true : false
    end
    
    def ie_version(ua_string)
      ua_string.match(/MSIE (\S+)/)[1].to_f
    end

    def kick_it
      [302, {'Location' => @options[:redirect]}, 'Fail browser is fail']
    end
  end
end