require 'spec_helper'

describe Site::AccountsController do
  before do
    init_rails_warden!
  end

  describe "#new" do
    it "stores a nonce into session" do
      get :new
      session[Nonce::SESSION_KEY].should be_present
    end
  end

  describe "#create" do
    before do
      @account = Factory.build(:password_account)
      @attrs = {"name" => @account.name, "login" => @account.login, "password" => "password"}
      @params = {"password_account" => @attrs}
    end

    it "redirects home on success" do
      PasswordAccount.should_receive(:register).with(@attrs).and_return(@account)
      post :create, @params
      response.should redirect_to root_path
    end
    
    it "logs the accounts user in on success" do
      PasswordAccount.should_receive(:register).with(@attrs).and_return(@account)
      post :create, @params
      request.env['warden'].user.should == @account.user
    end
    
    it "redirects to the stashed location if one is stashed in session on success" do
      PasswordAccount.should_receive(:register).with(@attrs).and_return(@account)
      session[:return_to] = "/random/path"
      post :create, @params
      response.should redirect_to "/random/path"
    end

    it "renders registration on failure" do
      @account.should_receive(:valid?).and_return(false)
      PasswordAccount.should_receive(:register).with(@attrs).and_return(@account)
      post :create, @params
      response.should render_template("site/accounts/new")
    end
    
    it "stores a nonce into session on failure" do
      @account.should_receive(:valid?).and_return(false)
      PasswordAccount.should_receive(:register).with(@attrs).and_return(@account)
      post :create, @params
      session[Nonce::SESSION_KEY].should be_present
    end
    

    it "sets a flash error message on failure" do
      @account.should_receive(:valid?).and_return(false)
      PasswordAccount.should_receive(:register).with(@attrs).and_return(@account)
      post :create, @params
      flash[:error].should be_present
    end
  end
end