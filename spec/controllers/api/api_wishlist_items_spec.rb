require 'spec_helper'

describe Api::WishlistItemsController do
  before { init_rails_warden! }
  
  describe "#create" do
    before :each do
      @user = Factory.create(:user)
      @wi = Factory.create(:wishlist_item, :user => @user)
    end
    
    it "responds with 401 if not logged it" do
      post :create
      response.status.should == 401
    end

    it "responds with 409 if given a duplicate item for the current user" do
      login @user
      post :create, :item => {:item_type => @wi.item_type, :item_id => @wi.item_id}
      response.status.should == 409
    end

    it "responds with the duplicated wishlist item when given a duplicate item" do
      login @user
      post :create, :item => {:item_type => @wi.item_type, :item_id => @wi.item_id}
      json = response.body
      hash = JSON.parse(json)
      hash["id"].should == @wi.id
    end

    it "succeeds given a new item for the current user" do
      newi = Factory.create(:place)
      login @user
      post :create, :item => {:item_type => newi.class.to_s, :item_id => newi.id}
      response.status.should == 200
    end

    it "responds with a new wishlist item given a new item for the current user" do
      newi = Factory.create(:place)
      old_max = @user.wishlist_items.maximum(:id)
      login @user
      post :create, :item => {:item_type => newi.class.to_s, :item_id => newi.id}
      json = response.body
      hash = JSON.parse(json)
      hash["id"].should > old_max
    end
  end
  
  describe "#destroy" do
    before :each do 
      @user = Factory.create(:user)
      @item = Factory.create(:wishlist_item, :user => @user)
    end

    it "responds with 401 if not logged it" do
      delete :destroy, :id => @item.id
      response.status.should == 401
    end
    
    it "responds with success if logged in and given a valid id" do
      login @user
      delete :destroy, :id => @item.id
      response.status.should == 200
    end

    it "responds with 404 if logged in and given an invalid id" do
      login @user
      delete :destroy, :id => -1
      response.status.should == 404
      login @user
      delete :destroy, :id => "invalid"
      response.status.should == 404
    end
    
    it "responds with 404 if the item owning the id belongs to another user" do
      user2 = Factory.create(:user)
      item2 = Factory.create(:wishlist_item, :user => user2)
      login @user
      delete :destroy, :id => item2.id
      response.status.should == 404
    end
    
    it "deletes the item with given id if it belongs to the logged in user" do
      login @user
      delete :destroy, :id => @item.id
      WishlistItem.find_by_id(@item.id).should be_deleted
    end
  end
end