module Spot
  module Spec
    def env_with_params(path = "/", params = {})
      method = params.fetch(:method, "GET")
      Rack::MockRequest.env_for(path, :params => params,
                                     'HTTP_VERSION' => '1.1',
                                     'REQUEST_METHOD' => "#{method}")
    end
    
    def init_rails_warden!
      manager = RailsWarden::Manager.new({}) do |manager|
        manager.default_strategies :cookie, :device
      end    
      request.env["warden"] = Warden::Proxy.new(request.env, manager)
    end
    
    def login(user)
      request.env["warden"].set_user user
    end
  end
end