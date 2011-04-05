require 'spec_helper'

describe Site::EmailsController do
  before do
    @email = Factory.next(:email)
  end
  
  describe "#show" do
    it "redirects to the root path if no email param is provided" do
      get :show
      response.should redirect_to(root_path)
    end

    it "does not redirect if an email param is provided" do
      get :show, :email => @email
      response.should_not be_redirect
    end
  end
  
  describe "#unsubscribe" do
    it "should block the email param" do
      get :unsubscribe, :email => @email
      BlockedEmail.blocked?(@email).should == true
    end

    it "should redirect to goodbye" do
      get :unsubscribe, :email => @email
      response.should redirect_to(goodbye_email_path)
    end
  end
end