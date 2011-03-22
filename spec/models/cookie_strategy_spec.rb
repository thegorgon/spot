require 'spec_helper'

describe Strategies::Cookie do
  SECRET_TOKEN = "f7b0bea8937f01920be286123adb10e4"
  
  before :each do 
    @user = Factory.create(:user)
    @env = rack_env("/", {})
    @env["action_dispatch.secret_token"] = SECRET_TOKEN
    @verifier = ActiveSupport::MessageVerifier.new(SECRET_TOKEN)
    @cookie_value = Strategies::Cookie.cookie_value(@user)[:value]
    @cookie = "#{Strategies::Cookie.cookie_key}=#{@verifier.generate(@cookie_value)}; path=/; domain=.rails.local;"
  end
  
  it "should setup the spec correctly" do
    @env["HTTP_COOKIE"] = @cookie
    req = ActionDispatch::Request.new(@env)
    req.cookie_jar.signed[Strategies::Cookie.cookie_key].should == Strategies::Cookie.cookie_value(@user)[:value]
  end
  
  describe "#valid" do
    it "returns true if the cookie key exists" do
      @env["HTTP_COOKIE"] = @cookie
      strategy = Strategies::Cookie.new(@env)
      strategy.should be_valid
    end
    
    it "returns false if the cookie key does not exist" do
      @env["HTTP_COOKIE"] = "nothing=stupid; path=/; domain=.rails.local;"
      strategy = Strategies::Cookie.new(@env)
      strategy.should_not be_valid
      @env["HTTP_COOKIE"] = nil
      strategy = Strategies::Cookie.new(@env)
      strategy.should_not be_valid
    end
  end
  
  describe "#authenticate" do
    it "succeeds if the token and id match a user" do
      @env["HTTP_COOKIE"] = @cookie
      strategy = Strategies::Cookie.new(@env)
      strategy.authenticate!
      strategy.result.should == :success
    end

    it "fails if the token and id do not match a user" do
      @env["HTTP_COOKIE"] = "#{Strategies::Cookie.cookie_key}=#{@verifier.generate("nottherighttoken::#{@user.id}")}; path=/; domain=.rails.local;"
      strategy = Strategies::Cookie.new(@env)
      strategy.authenticate!
      strategy.result.should == :failure
      @env["HTTP_COOKIE"] = "#{Strategies::Cookie.cookie_key}=#{@verifier.generate("#{@user.persistence_token}::-1")}; path=/; domain=.rails.local;"
      strategy = Strategies::Cookie.new(@env)
      strategy.authenticate!
      strategy.result.should == :failure
    end
  end
end