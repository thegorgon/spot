require 'spec_helper'

describe User do
  before :each do 
    @user = Factory.build(:user)
  end
  
  describe "#wishlist" do
    before do 
      @user.save
    end

    it "returns a wishlist item to the item params provided" do
      item = Factory.create(:place)
      @wi = @user.wishlist(:item_type => item.class.to_s, :item_id => item.id)
      @wi.class.should == WishlistItem
      @wi.item.should == item
    end
    
    it "returns a new wishlist item if one does not exist for the item provided" do
      item = Factory.create(:place)
      @wi = @user.wishlist(:item_type => item.class.to_s, :item_id => item.id)
      @wi.should be_new_record
    end
    
    it "returns an existing wishlist item if one already exists for the item provided" do
      item = Factory.create(:place)
      @wi = @user.wishlist(:item_type => item.class.to_s, :item_id => item.id)
      @dupe = @user.wishlist(:item_type => item.class.to_s, :item_id => item.id)
      @dupe.id.should == @wi.id
    end
    
    it "returns a new wishlist item if one exists with the item provided but was destroyed" do
      item = Factory.create(:place)
      @wi = @user.wishlist(:item_type => item.class.to_s, :item_id => item.id)
      @wi.destroy
      @dupe = @user.wishlist(:item_type => item.class.to_s, :item_id => item.id)
      @dupe.should be_new_record
    end

    it "returns a valid wishlist item if one exists with the item provided but was destroyed" do
      item = Factory.create(:place)
      @wi = @user.wishlist(:item_type => item.class.to_s, :item_id => item.id)
      @wi.destroy
      @dupe = @user.wishlist(:item_type => item.class.to_s, :item_id => item.id)
      expect { @dupe.save! }.to_not raise_error
    end
    
    it "returns a wishlist item with teh given source attributes if it is a new record" do
      item = Factory.create(:place)
      source = Factory.create(:wishlist_item, :item => item)
      @wi = @user.wishlist(:item_type => item.class.to_s, :item_id => item.id, :source_type => source.class.to_s, :source_id => source.id)
      @wi.should be_new_record
      @wi.source.should == source
    end
  end
  
  describe "#tokens" do
    it "ensures the existence of a persistence token on save" do
      @user = Factory.create(:user, :persistence_token => nil)
      @user.persistence_token.should be_present
      @user.persistence_token = nil
      @user.save
      @user.persistence_token.should be_present      
    end
    
    it "ensures the existence of a single access token" do
      @user = Factory.create(:user, :single_access_token => nil)
      @user.single_access_token.should be_present
      @user.single_access_token = nil
      @user.save
      @user.single_access_token.should be_present      
    end
    
    it "resets perishable tokens every save" do
      @user = Factory.create(:user, :perishable_token => nil)
      @user.perishable_token.should be_present
      expect { @user.save }.to change(@user, :perishable_token)
    end
  end
  
  describe "#login" do
    before { @user.save }
    
    it "increments the users login count" do
      expect { @user.login!; @user.reload }.to change(@user, :login_count).by(1)
    end

    it "updates the current login date" do
      expect { @user.login!; @user.reload }.to change(@user, :current_login_at)
    end

    it "updates the updated date" do
      expect { @user.login!; @user.reload }.to change(@user, :updated_at)
    end
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
    
    it "moves devices from the new user to the old user" do
      @device = Factory.create(:device, :user => @new_user)
      @user.merge_with!(@new_user)
      @device.reload
      @device.user.should == @user
    end
    
    it "moves password accounts from the new user to the old user" do
      @account = Factory.create(:password_account, :user => @new_user)
      @user.merge_with!(@new_user)
      @account.reload
      @account.user.should == @user
    end

    it "moves facebook accounts from the new user to the old user" do
      @account = Factory.create(:facebook_account, :user => @new_user)
      @user.merge_with!(@new_user)
      @account.reload
      @account.user.should == @user
    end
  end
  
  describe "#find_using_perishable_token" do
    before { @user.save }
    
    it "returns a user with the given token if one exists and the token is younger than the age provided" do
      token_age = Time.now - @user.updated_at
      user = User.find_using_perishable_token(@user.perishable_token, token_age + 5.minutes)
      user.should == @user
    end

    it "returns a user with the given token if one exists, no age is provided and the token is younger than 1 hour old" do
      @user.updated_at = Time.now - 55.minutes
      @user.save
      user = User.find_using_perishable_token(@user.perishable_token)
      user.should == @user
    end
    
    it "returns nil if no user exists with the given token" do
      user = User.find_using_perishable_token("invalidtoken")
      user.should be_nil
    end
    
    it "returns nil if the token is older than the age provided" do
      @user.updated_at = Time.now - 30.minutes # Can't do the same token_age - x.minutes trick, because it'll probably be negative
      @user.save
      user = User.find_using_perishable_token(@user.perishable_token, 25.minutes)
      user.should be_nil      
    end

    it "returns nil if the token is older than 1 hour old and no age is provided" do
      @user.updated_at = Time.now - 65.minutes
      @user.save
      user = User.find_using_perishable_token(@user.perishable_token)
      user.should be_nil
    end
    
    it "returns nil if no token is provided" do
      user = User.find_using_perishable_token("")
      user.should be_nil
      user = User.find_using_perishable_token(nil)
      user.should be_nil
    end

    it "ignores the token age if the provided age is under 0" do
      @user.updated_at = Time.now - 1.year
      @user.save
      user = User.find_using_perishable_token(@user.perishable_token, -1)
      user.should == @user
    end
  end
end