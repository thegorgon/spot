module Spot
  module Spec
    def rack_env(path = "/", params = {}, session = {})
      method = params.fetch(:method, "GET")
      env = Rack::MockRequest.env_for(path, :params => params,
                                     'HTTP_VERSION' => '1.1',
                                     'REQUEST_METHOD' => "#{method}")
      env["rack.session"] = session
      env
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
    
    def stub_nonce!(nonce, result)
      Nonce.should_receive(:valid?).any_number_of_times do |params, session|
        params[:credentials].should be_kind_of(Hash)
        params[:credentials][:key].should == nonce.digested
        result
      end
    end
  end
end