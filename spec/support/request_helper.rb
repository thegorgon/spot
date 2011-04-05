module Spot
  module Spec
    def rack_env(path = "/", params = {})
      options = {}
      options[:method] = params.delete(:method)
      options[:params] = params
      env = Rack::MockRequest.env_for(path, options)
      env["rack.session"] = {}
      env
    end
    
    def init_rails_warden!
      manager = RailsWarden::Manager.new({}) do |manager|
        manager.failure_app = Site::SessionsController
        manager.default_scope = :user
        manager.scope_defaults(
          :user,
          :action     => :new,
          :strategies => [:facebook, :password, :perishable_token, :device, :cookie]
        )
      end    
      request.env["warden"] = Warden::Proxy.new(request.env, manager)
    end
    
    def mock_mail
      mock(Mail, :deliver! => true)
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
    
    def process_with_query(action, query_string="", parameters = nil, session = nil, flash = nil, http_method = 'GET')
      # Sanity check for required instance variables so we can give an
      # understandable error message.
      %w(@routes @controller @request @response).each do |iv_name|
        if !(instance_variable_names.include?(iv_name) || instance_variable_names.include?(iv_name.to_sym)) || instance_variable_get(iv_name).nil?
          raise "#{iv_name} is nil: make sure you set it in your test's setup method."
        end
      end
    
      @request.recycle!
      @response.recycle!
      @controller.response_body = nil
      @controller.formats = nil
      @controller.params = nil
    
      @html_document = nil
      @request.env['REQUEST_METHOD'] = http_method
    
      parameters ||= {}
      @request.assign_parameters(@routes, @controller.class.name.underscore.sub(/_controller$/, ''), action.to_s, parameters)
    
      @request.session = ActionController::TestSession.new(session) unless session.nil?
      @request.session["flash"] = @request.flash.update(flash || {})
      @request.session["flash"].sweep
    
      @controller.request = @request
      @controller.params.merge!(parameters)
      build_request_uri(action, parameters)
      @request.env["QUERY_STRING"] = query_string.kind_of?(Hash) ? query_string.to_param : query_string
      @request.env["action_dispatch.request.query_parameters"] = Rack::Utils.parse_query(@request.env["QUERY_STRING"])
      ActionController::Base.class_eval { include ActionController::Testing }
      @controller.process_with_new_base_test(@request, @response)
      @request.session.delete('flash') if @request.session['flash'].blank?
      @response
    end

    def put_with_query(action, query_string="", parameters=nil, session=nil, flash=nil)
      process_with_query(action, query_string, parameters, session, flash, 'PUT')
    end

    def post_with_query(action, query_string="", parameters=nil, session=nil, flash=nil)
      process_with_query(action, query_string, parameters, session, flash, 'POST')
    end
  end
end