require 'spec_helper'

describe Strategies::Password do
  before :each do 
    @nonce = Nonce.new
    @session = {}
    @password = "testpass"
    @account = Factory.create(:password_account, :login => "tester@test.com", :password => @password)
    @params = { :credentials => { :password => { :login => @account.login, :password => @password }, :key => @nonce.digested } }
    @env = rack_env("/", @params)
  end
  
  it "should setup the spec correctly" do
    req = Rack::Request.new(@env)
    req.params["credentials"]["password"]["login"].should == @account.login
    req.params["credentials"]["password"]["password"].should == @password
    req.params["credentials"]["key"].should == @nonce.digested
  end
  
  describe "#valid" do
    before { stub_nonce!(@nonce, true) }
    it "returns true if the params include a login, password" do
      Strategies::Password.new(@env).should be_valid
    end

    it "returns false if the params do not include a login" do
      @params[:credentials][:password][:login] = nil
      env = rack_env("/", @params)
      Strategies::Password.new(env).should_not be_valid
    end

    it "returns false if the params do not include a password " do
      @params[:credentials][:password][:password] = nil
      env = rack_env("/", @params)
      Strategies::Password.new(env).should_not be_valid
    end

    it "returns false if the params are improperly formatted" do
      @params[:credentials][:password] = {}
      env = rack_env("/", @params)
      Strategies::Password.new(env).should_not be_valid
      @params[:credentials][:password] = nil
      env = rack_env("/", @params)
      Strategies::Password.new(env).should_not be_valid
      @params[:credentials] = nil
      env = rack_env("/", @params)
      Strategies::Password.new(env).should_not be_valid
    end
  end
  
  describe "#authenticate" do    
    it "succeeds if the params include valid password credentials and a valid nonce" do
      stub_nonce!(@nonce, true)
      strategy = Strategies::Password.new(@env)
      strategy.authenticate!
      strategy.result.should == :success
    end
    
    it "binds the device to the user if given device parameters" do
      stub_nonce!(@nonce, true)
      @device = Factory.create(:device)
      @params[:credentials][:device] = {:id => @device.udid, :os_id => @device.os_id, :app_version => @device.app_version}
      env = rack_env("/", @params)
      strategy = Strategies::Password.new(env)
      strategy.authenticate!
      strategy.result.should == :success
      @device.reload
      @account.reload
      @device.user_id.should == @account.user_id
    end
    
    it "fails if the nonce is invalid" do
      stub_nonce!(@nonce, false)
      env = rack_env("/", @params)
      strategy = Strategies::Password.new(env)
      strategy.authenticate!
      strategy.result.should == :failure
    end
    
    it "fails if the login is incorrect" do
      stub_nonce!(@nonce, true)
      @params[:credentials][:password][:login] = "wronglogin"
      env = rack_env("/", @params)
      strategy = Strategies::Password.new(env)
      strategy.authenticate!
      strategy.result.should == :failure
    end
    
    it "fails if the password is incorrect" do
      stub_nonce!(@nonce, true)
      @params[:credentials][:password][:password] = "wrongpassword"
      env = rack_env("/", @params)
      strategy = Strategies::Password.new(env)
      strategy.authenticate!
      strategy.result.should == :failure      
    end
  end
end