require 'spec_helper'

describe Strategies::Device do
  before :each do 
    @nonce = Nonce.new
    @device = Factory.create(:device)
    @params = { :credentials => { :device => { :id => @device.udid, :os_id => @device.os_id, :platform => @device.platform }, :key => @nonce.digested } }
    @env = rack_env("/", @params)
  end
  
  it "should setup the spec correctly" do
    req = Rack::Request.new(@env)
    req.params["credentials"]["device"]["id"].should == @device.udid
    req.params["credentials"]["device"]["os_id"].should == @device.os_id
    req.params["credentials"]["device"]["platform"].should == @device.platform
    req.params["credentials"]["key"].should == @nonce.digested
  end
  
  describe "#valid" do
    before { stub_nonce!(@nonce, true) }
    it "returns true if the params include the device params" do
      Strategies::Device.new(@env).should be_valid
    end

    it "returns true if the params include the device id" do
      @params[:credentials][:device][:os_id] = nil
      @params[:credentials][:device][:platform] = nil
      env = rack_env("/", @params)
      Strategies::Device.new(env).should be_valid
    end

    it "returns false if the params do not include a device id" do
      @params[:credentials][:device][:id] = nil
      env = rack_env("/", @params)
      Strategies::Device.new(env).should_not be_valid
    end

    it "returns false if the params are improperly formatted" do
      @params[:credentials][:device] = {}
      env = rack_env("/", @params)
      Strategies::Password.new(env).should_not be_valid
      @params[:credentials][:device] = nil
      env = rack_env("/", @params)
      Strategies::Password.new(env).should_not be_valid
      @params[:credentials] = nil
      env = rack_env("/", @params)
      Strategies::Password.new(env).should_not be_valid
    end
  end
  
  describe "#authenticate" do
    it "succeeds if the params include a valid nonce and valid device params" do
      stub_nonce!(@nonce, true)
      env = rack_env("/", @params)
      strategy = Strategies::Device.new(env)
      strategy.authenticate!
      strategy.result.should == :success
    end

    it "fails if the params do not include valid device params" do
      stub_nonce!(@nonce, true)
      @params[:credentials][:device] = nil
      env = rack_env("/", @params)
      strategy = Strategies::Device.new(env)
      strategy.authenticate!
      strategy.result.should == :failure
    end
    
    it "fails without a valid nonce token" do
      stub_nonce!(@nonce, false)
      env = rack_env("/", @params)
      strategy = Strategies::Device.new(env)
      strategy.authenticate!
      strategy.result.should == :failure
    end    
  end
end