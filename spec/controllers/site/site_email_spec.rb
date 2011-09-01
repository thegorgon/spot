require 'spec_helper'

describe Site::EmailsController do
  before do
    init_rails_warden!
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
end