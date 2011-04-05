require 'spec_helper'

describe Site::PasswordResetsController do
  before do
    init_rails_warden!
    @account = Factory.create(:password_account)
  end

  describe "#new" do
    it "responds with success" do
      get :new
      response.should be_success
    end
  end
  
  describe "#create" do
    before { @params = {:reset => {:login => @account.login}} }

    it "redirects to the login page if given a valid login" do
      post :create, @params
      response.should redirect_to(new_session_path)
    end
    
    it "resets the users perishable token if given a valid login" do
      token = @account.user.perishable_token
      post :create, @params
      @account.user.reload
      @account.user.perishable_token.should_not == token
    end

    it "sends a password reset email to the user if given a valid login" do
      TransactionMailer.should_receive(:password_reset).with(@account.user).and_return(mock_mail)
      post :create, @params
    end

    it "sets a flash notice message if given a valid login" do
      post :create, @params
      flash[:notice].should be_present
    end

    it "redirects to new if given an invalid email" do
      @params[:reset][:login] = "nil"
      post :create, @params
      response.should redirect_to(:action => "new")
    end    

    it "sets a flash error message if given a valid login" do
      @params[:reset][:login] = "nil"
      post :create, @params
      flash[:error].should be_present
    end

    it "fails gracefully with no params" do
      post :create, {}
      response.should be_redirect
    end
  end
  
  describe "#edit" do
    before do 
      @account.user.reset_perishable_token!
      @token = @account.user.perishable_token
    end
    
    it "redirects to home without a token" do
      get :edit
      response.should redirect_to(root_url)
    end

    it "sets an error message in flash without a valid token" do
      get :edit
      flash[:error].should be_present
    end

    it "succeeds with a valid token" do
      get :edit, "token" => @token
      response.should be_success
    end
  end
    
  describe "#update" do
    before do
      @user = @account.user
      @user.reset_perishable_token!
      @token = @user.perishable_token
      @path = password_reset_path(:token => @token)
      @newpass = "newpassword"
      @params = {:reset => {:password => @newpass}}
    end

    it "redirects to home without a token" do
      put :update, {}, @params
      response.should redirect_to(root_url)
    end

    it "redirects to home without a token even if you're logged in" do
      login @user
      put :update, {}, @params
      response.should redirect_to(root_url)
    end

    it "sets an error message in flash without a valid token" do
      put :update, {}, @params
      flash[:error].should be_present
    end
    
    it "updates the account password to the provided value" do
      put_with_query(:update, {:token => @token}, @params)
      @account.reload.crypted_password.should == PasswordAccount.encrypt(@newpass, @account.password_salt)
    end    

    it "sets a flash notice message on success" do
      process_with_query(:update, {:token => @token}, @params)
      flash[:notice].should be_present
    end
    
    it "redirects to the login page on success" do
      process_with_query(:update, {:token => @token}, @params)
      response.should redirect_to(new_session_path)
    end
    
    it "redirects to edit if no password is provided" do
      @params[:reset][:password] = ""
      process_with_query(:update, {:token => @token}, @params)
      response.should redirect_to(:action => :edit)      
    end

    it "fails gracefully with no params" do
      process_with_query(:update, {:token => @token}, {})
      response.should redirect_to(:action => :edit)      
    end

    it "sets an error message in flash if no password is provided" do
      @params[:reset][:password] = ""
      process_with_query(:update, {:token => @token}, {})
      flash[:error].should be_present
    end
    
    it "resets the users perishable token on success" do
      put_with_query(:update, {:token => @token}, @params)
      @user.reload.perishable_token.should_not == @token
    end
  end
end