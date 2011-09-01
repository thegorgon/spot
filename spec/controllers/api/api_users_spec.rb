require 'spec_helper'

describe Api::UsersController do
  before(:all) do 
    User.delete_all
    @user = Factory.create(:user)
    @viewer = Factory.create(:user)
  end
  before { init_rails_warden! }

  describe "#show" do
    it "renders a user" do
      login @viewer
      get :show, :id => @user.id
      JSON.parse(response.body).should == @user.as_json
    end
    
    it "fails if not logged in" do
      get :show, :id => @user.id
      response.status.should == 401      
    end
  end
  
  describe "#update" do
    it "fails if not logged in" do
      put :update, :id => @user.id, :user => {:email => "newemail@new.new"}
      response.status.should == 401      
    end
    
    it "fails if not logged in as the user" do
      login @viewer
      put :update, :id => @user.id, :user => {:email => "newemail@new.new"}
      response.status.should == 401      
    end
    
    it "updates the users parameters" do 
      login @user
      put :update, :id => @user.id, :user => {:email => "newemail@new.new"}
      response.status.should == 200
      @user.reload.email.should == "newemail@new.new"
    end
  end
end