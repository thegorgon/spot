describe Strategies::Device do
  before :each do 
    @device = Factory.create(:device)
    @session = {}
    @nonce = Nonce.new(:session => @session)
    @params = { :credentials => { :device => { :id => @device.udid, :os_id => @device.os_id, :platform => @device.platform }, :key => @nonce.digested } }
    @env = env_with_params("/", @params)
  end
  
  it "should setup the spec correctly" do
    req = Rack::Request.new(@env)
    req.params["credentials"]["device"]["id"].should == @device.udid
    req.params["credentials"]["device"]["os_id"].should == @device.os_id
    req.params["credentials"]["device"]["platform"].should == @device.platform
  end
  
  describe "#valid" do
    it "returns true if the params include the device id and a credential key" do
      @env["rack.session"] = @session
      Strategies::Device.new(@env).should be_valid
    end

    it "returns false if the params do not include the device id and a credential key" do
      env = env_with_params("/", {})
      Strategies::Device.new(env).should_not be_valid
      env = env_with_params("/", {:credentials => { :device => nil }, :key => @nonce.token})
      Strategies::Device.new(env).should_not be_valid
      env = env_with_params("/", {:credentials => nil, :key => @nonce.token})
      Strategies::Device.new(env).should_not be_valid
      env = env_with_params("/", {:credentials => { :device => {} }, :key => @nonce.token})
      Strategies::Device.new(env).should_not be_valid
    end    
  end
  
  describe "#authenticate" do
    it "succeeds if the params include a valid nonce token and valid device params" do
      env = env_with_params("/", @params)
      env["rack.session"] = @session
      strategy = Strategies::Device.new(env)
      strategy.authenticate!
      strategy.result.should == :success
    end

    it "fails if the params do not include valid device params" do
      env = env_with_params("/", { :credentials => @params[:credentials].except(:device) })
      env["rack.session"] = @session
      strategy = Strategies::Device.new(env)
      strategy.authenticate!
      strategy.result.should == :failure
    end
    
    it "fails if the params do not include a valid nonce token" do
      env = env_with_params("/", { :credentials => @params[:credentials].except(:key) })
      env["rack.session"] = @session
      strategy = Strategies::Device.new(env)
      strategy.authenticate!
      strategy.result.should == :failure
    end

    it "fails if the session does not include the nonce" do
      env = env_with_params("/", @params)
      env["rack.session"] = {}
      strategy = Strategies::Device.new(env)
      strategy.authenticate!
      strategy.result.should == :failure
    end
    
  end
end