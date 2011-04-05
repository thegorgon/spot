require 'spec_helper'

describe Strategies::PerishableToken do
  before :each do 
    @nonce = Nonce.new
    @session = {}
    @user = Factory.create(:user)
    @post_params = { :credentials => { :token => @user.perishable_token, :key => @nonce.digested }, :method => "POST" }
    @post_env = rack_env("/", @post_params)
    @get_params = { :token => @user.perishable_token, :method => "GET"}
    @get_env = rack_env("/", @get_params)
  end
  
  it "should setup the spec correctly" do
    post_req = Rack::Request.new(@post_env)
    post_req.POST["credentials"]["token"].should == @user.perishable_token
    post_req.POST["credentials"]["key"].should == @nonce.digested
    post_req.POST["method"].should be_nil
    get_req = Rack::Request.new(@get_env)
    get_req.GET["token"].should == @user.perishable_token
    get_req.GET["method"].should be_nil
  end

  describe "#token" do
    it "returns the token in the POST params if the POST params include a token" do
      strategy = Strategies::PerishableToken.new(@post_env)
      strategy.token.should == @user.perishable_token
    end

    it "returns the token in the GET params if the GET params include a token" do
      strategy = Strategies::PerishableToken.new(@get_env)
      strategy.token.should == @user.perishable_token
    end
        
    it "returns nil on POST if the POST params do not include a token" do
      @post_params[:credentials][:token] = nil
      env = rack_env("/", @post_params)
      strategy = Strategies::PerishableToken.new(env)
      strategy.token.should be_nil
      @post_params[:credentials] = nil
      env = rack_env("/", @post_params)
      strategy = Strategies::PerishableToken.new(env)
      strategy.token.should be_nil
    end
    
    it "returns nil on GET if the GET params do not include a perishable token" do
      @get_params[:token] = nil
      env = rack_env("/", @get_params)
      strategy = Strategies::PerishableToken.new(env)
      strategy.token.should be_nil
    end
    
    it "returns nil if the param format does not match the request method" do
      @post_params[:method] = "GET"
      env = rack_env("/", @post_params)
      strategy = Strategies::PerishableToken.new(env)
      strategy.token.should be_nil
      @get_params[:method] = "POST"
      env = rack_env("/", @get_params)
      strategy = Strategies::PerishableToken.new(env)
      strategy.token.should be_nil
    end    
  end

  describe "#valid?" do
    before { @strategy = Strategies::PerishableToken.new(rack_env("/", {})) }

    it "returns true if the token is present" do
      @strategy.should_receive(:token).and_return(@user.perishable_token)
      @strategy.should be_valid
    end
    
    it "returns false if the token is nil" do
      @strategy.should_receive(:token).and_return(nil)
      @strategy.should_not be_valid
    end     

    it "returns false if the token is empty" do
      @strategy.should_receive(:token).and_return("")
      @strategy.should_not be_valid
    end     
  end
  
  describe "#store?" do
    before { @strategy = Strategies::PerishableToken.new(rack_env("/", {})) }

    it "should return false" do
      @strategy.store?.should == false
    end
  end
  
  describe "#authenticate!" do
    before { @strategy = Strategies::PerishableToken.new(rack_env("/", {})) }
    
    it "succeeds if the token matches a valid user's token" do
      @strategy.should_receive(:token).and_return(@user.perishable_token)
      @strategy.authenticate!
      @strategy.result.should == :success
    end
    
    it "fails if the token does not match any user's token" do
      @strategy.should_receive(:token).and_return("invalidusertoken")
      @strategy.authenticate!
      @strategy.result.should == :failure
    end
    
    it "fails if the token is expired" do
      @user.updated_at = Time.now - 1.day - 1.minute
      @user.save
      @strategy.should_receive(:token).and_return(@user.perishable_token)
      @strategy.authenticate!
      @strategy.result.should == :failure      
    end
    
    it "binds the device to the user if given device parameters and a valid nonce" do
      @nonce = Nonce.new
      @post_params[:credentials][:key] = @nonce.digested
      stub_nonce!(@nonce, true)
      @device = Factory.create(:device)
      @post_params[:credentials][:device] = {:id => @device.udid, :os_id => @device.os_id, :app_version => @device.app_version}
      @post_params[:method] = "POST"
      env = rack_env("/", @post_params)
      strategy = Strategies::PerishableToken.new(env)
      strategy.token.should == @user.perishable_token
      strategy.authenticate!
      strategy.result.should == :success
      @device.reload
      @user.reload
      @device.user_id.should == @user.id
    end
    
    it "does not bind the device to the user without a valid nonce" do
      @nonce = Nonce.new
      @post_params[:credentials][:key] = @nonce.digested
      stub_nonce!(@nonce, false)
      @device = Factory.create(:device)
      @post_params[:credentials][:device] = {:id => @device.udid, :os_id => @device.os_id, :app_version => @device.app_version}
      @post_params[:method] = "POST"
      env = rack_env("/", @post_params)
      strategy = Strategies::PerishableToken.new(env)
      strategy.token.should == @user.perishable_token
      strategy.authenticate!
      strategy.result.should == :success
      @device.reload
      @user.reload
      @device.user_id.should_not == @user.id
    end
  end
end