require 'spec_helper'

describe Api::WishlistsController do
  before { init_rails_warden! }
  
  describe "#show" do
    before :each do 
      @user = Factory.create(:user)
      10.times { Factory.create(:wishlist_item, :user => @user) }
    end
    
    it "responds with 401 if not logged it" do
      get :show
      response.status.should == 401
    end

    it "responds with success if logged in" do
      login @user
      get :show
      response.status.should == 200
    end

    it "responds with the current users wishlist as json if logged in" do
      login @user
      get :show
      json = response.body
      json.should == @user.wishlist_items.active.to_json
    end
    
    it "does not include deleted wishlist items" do
      @user.wishlist_items.map(&:destroy)
      @user.wishlist_items.active.should be_empty
      login @user
      get :show
      json = response.body
      array = JSON.parse(response.body)
      array.should be_empty
    end
  end
end