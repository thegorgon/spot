require 'spec_helper'

describe Strategies::Facebook do
  before :each do 
    @nonce = Nonce.new
    @session = {}
    @account = Factory.create(:facebook_account)
    @params = { :credentials => { :facebook => { :facebook_id => @account.facebook_id.to_s, :access_token => @account.access_token, :else => 1 }, :key => @nonce.digested } }
    @env = rack_env("/", @params)
  end
  
  it "should setup the spec correctly" do
    req = Rack::Request.new(@env)
    req.params["credentials"]["facebook"]["facebook_id"].to_i.should == @account.facebook_id
    req.params["credentials"]["facebook"]["access_token"].should == @account.access_token
    req.params["credentials"]["key"].should == @nonce.digested
  end
  
  describe "#valid?" do
    before { stub_nonce!(@nonce, true) }
    
    it "returns true if the credentials include a facebook id and an access token" do
      Strategies::Facebook.new(@env).should be_valid
    end

    it "returns false without a facebook id" do
      @params[:credentials][:facebook][:facebook_id] = nil
      env = rack_env("/", @params)
      Strategies::Facebook.new(env).should_not be_valid
    end

    it "returns false without an access token" do
      @params[:credentials][:facebook][:access_token] = nil
      env = rack_env("/", @params)
      Strategies::Facebook.new(env).should_not be_valid
    end

    it "returns false if the params are improperly formatted" do
      @params[:credentials][:facebook] = {}
      env = rack_env("/", @params)
      Strategies::Facebook.new(env).should_not be_valid
      @params[:credentials][:facebook] = nil
      env = rack_env("/", @params)
      Strategies::Facebook.new(env).should_not be_valid
      @params[:credentials] = nil
      env = rack_env("/", @params)
      Strategies::Facebook.new(env).should_not be_valid
    end
  end
  
  describe "#authenticate!" do
    before :each do
      @mock_user = Wrapr::FbGraph::User.new
      @mock_user.id = @account.facebook_id
    end
    
    it "succeeds if the params include a valid nonce and valid facebook params" do
      stub_nonce!(@nonce, true)
      Wrapr::FbGraph::User.should_receive(:find).and_return(@mock_user)      
      strategy = Strategies::Facebook.new(@env)
      strategy.authenticate!
      strategy.result.should == :success
    end

    it "binds the device to the user if given device parameters" do
      stub_nonce!(@nonce, true)
      Wrapr::FbGraph::User.should_receive(:find).and_return(@mock_user)      
      @device = Factory.create(:device)
      @params[:credentials][:device] = {:id => @device.udid, :os_id => @device.os_id, :app_version => @device.app_version}
      env = rack_env("/", @params)
      strategy = Strategies::Facebook.new(env)
      strategy.authenticate!
      @device.reload
      @account.reload
      @device.user_id.should == @account.user_id
    end

    it "fails if the params do not include valid facebook params" do
      stub_nonce!(@nonce, true)
      @params[:credentials][:facebook] = nil
      @env = rack_env("/", @params)
      strategy = Strategies::Facebook.new(@env)
      strategy.authenticate!
      strategy.result.should == :failure
    end

    it "fails if the nonce is invalid" do
      stub_nonce!(@nonce, false)
      strategy = Strategies::Facebook.new(@env)
      strategy.authenticate!
      strategy.result.should == :failure
    end
    
    it "fails if facebook responds with a different id" do
      stub_nonce!(@nonce, true)
      @mock_user.id = @account.facebook_id + 1
      Wrapr::FbGraph::User.should_receive(:find).and_return(@mock_user)      
      strategy = Strategies::Facebook.new(@env)
      strategy.authenticate!
      strategy.result.should == :failure
    end

    it "fails if facebook does not respond with a user" do
      stub_nonce!(@nonce, true)
      Wrapr::FbGraph::User.should_receive(:find).and_return(nil)
      strategy = Strategies::Facebook.new(@env)
      strategy.authenticate!
      strategy.result.should == :failure
    end
  end
end