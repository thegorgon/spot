require 'spec_helper'

describe Api::SessionsController do
  before :each do
    init_rails_warden!
    @token = "a1b2c3d4e5"
    @device = Factory.create :device
  end
  
  describe "#new" do
    it "responds with a nonce token" do
      get :new
      json = response.body
      hash = JSON.parse(json)
      hash["nonce"].should be_present
    end
    
    it "adds a nonce token into session" do
      get :new
      session[Nonce::SESSION_KEY].should be_present
    end
  end
  
  describe "#create" do
    it "responds with 401 without a nonce key" do
      post :create, {}
      response.status.should == 401
      post :create, {:credentials => {:device => {:id => @device.udid, :os_id => @device.os_id, :platform => @device.platform}}}
      response.status.should == 401
    end

    it "responds with 401 without credentials" do
      post :create, {}
      response.status.should == 401
      session[Nonce::SESSION_KEY] = @token
      post :create, {:credentials => {:key => Nonce.digest(@token)}}
      response.status.should == 401
    end

    it "responds with 401 if the nonce key is not in session" do
      post :create, {:credentials => {:key => Nonce.digest(@token), :device => {:id => @device.udid, :os_id => @device.os_id, :platform => @device.platform}}}
      response.status.should == 401
    end

    it "responds with a user with valid credentials and a valid token" do
      session[Nonce::SESSION_KEY] = @token
      post :create, {:credentials => {:key => Nonce.digest(@token), :device => {:id => @device.udid, :os_id => @device.os_id, :platform => @device.platform}}}
      response.should be_success
      response.body.should == {:user => @device.user}.to_json
    end

    it "clears the nonce token on success" do
      session[Nonce::SESSION_KEY] = @token
      post :create, {:credentials => {:key => Nonce.digest(@token), :device => {:id => @device.udid, :os_id => @device.os_id, :platform => @device.platform}}}
      session[Nonce::SESSION_KEY].should be_nil
    end

    it "clears the nonce token on failure" do
      session[Nonce::SESSION_KEY] = @token
      post :create, {:credentials => {:key => "1", :device => {:id => ""}}}
      session[Nonce::SESSION_KEY].should be_nil
    end
  end
  
  describe "#destroy" do
    it "responds with success if logged in" do
      login @device.user
      delete :destroy
      response.should be_success
    end

    it "responds with 401 if not logged in" do
      delete :destroy
      response.status.should == 401
    end
  end
end