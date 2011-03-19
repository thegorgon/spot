require 'spec_helper'

describe User do
  before :each do 
    @user = Factory.build(:user)
  end
  
  describe "#merge_with!" do
    before :each do 
      @user = Factory.create(:user)
      @new_user = Factory.create(:user)
    end
    
    it "destroys the item to be merged" do
      @user.merge_with!(@new_user)
      @new_user.should be_destroyed
    end
    
    it "moves new wishlist items to the user" do
      @new_item = Factory.create(:wishlist_item, :user => @new_user)
      @user.merge_with!(@new_user)
      @new_item.reload.user.should == @user
    end

    it "destroys duplicate wishlist items on the new user" do
      place = Factory.create(:place)
      @item = Factory.create(:wishlist_item, :user => @user, :item => place)
      @dupe_item = Factory.create(:wishlist_item, :user => @new_user, :item => place)
      @user.merge_with!(@new_user)
      WishlistItem.find_by_id(@dupe_item.id).should be_nil
    end
    
    it "leaves wishlist items on the user alone when changes are made" do
      place = Factory.create(:place)
      @item = Factory.create(:wishlist_item, :user => @user, :item => place)
      @dupe_item = Factory.create(:wishlist_item, :user => @new_user, :item => place)      
      @new_item = Factory.create(:wishlist_item, :user => @new_user)
      @clone = @item.clone
      @user.merge_with!(@new_user)
      @item.reload
      [:item, :user, :source_type, :source_id, :deleted_at].each do |key|
        @clone.send(key).should == @item.send(key)
      end
    end
    
  end
  

end