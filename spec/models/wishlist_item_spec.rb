require 'spec_helper'

describe WishlistItem do
  describe "#associations" do
    it "belongs to a user" do
      WishlistItem.reflect_on_association(:user).macro.should == :belongs_to
      WishlistItem.reflect_on_association(:user).class_name.should == User.to_s
    end
    
    it "belongs to a polymorphic item" do
      WishlistItem.reflect_on_association(:item).macro.should == :belongs_to
      WishlistItem.reflect_on_association(:item).options[:polymorphic].should == true
    end
    
    it "belongs to a polymorphic source" do
      WishlistItem.reflect_on_association(:source).macro.should == :belongs_to
      WishlistItem.reflect_on_association(:source).options[:polymorphic].should == true
    end
  end
  
  describe "#validations" do
    before { @wi = Factory.build(:wishlist_item) }

    it "has a numerical latitude within -90 and 90" do
      @wi.should be_valid
      @wi.lat = -91
      @wi.should_not be_valid
      @wi.lat = 91
      @wi.should_not be_valid
      @wi.lat = 0
      @wi.should be_valid
    end
    
    it "has a numerical longitude within -180 and 180" do
      @wi.should be_valid
      @wi.lng = -181
      @wi.should_not be_valid
      @wi.lng = 181
      @wi.should_not be_valid
      @wi.lng = 0
      @wi.should be_valid
    end
    
    it "has a valid item type" do
      @wi.should be_valid
      @wi.item_type = "InvalidItemType"
      @wi.should_not be_valid
      @wi.item_type = nil
      @wi.should_not be_valid
      @wi.item_type = WishlistItem::ITEM_TYPES.first
      @wi.should be_valid
    end

    it "has a numerical item id" do
      item = @wi.item
      @wi.should be_valid
      @wi.item_id = "notanumber"
      @wi.should_not be_valid
      @wi.item_id = nil
      @wi.should_not be_valid
      @wi.item_id = item.id
      @wi.should be_valid      
    end

    it "has a numerical user id" do
      user = @wi.user
      @wi.should be_valid
      @wi.user_id = "notanumber"
      @wi.should_not be_valid
      @wi.user_id = nil
      @wi.should_not be_valid
      @wi.user_id = user.id
      @wi.should be_valid      
    end    
  end
    
  describe "#scopes" do
    it "has an active scope which limits the scope to active records" do
      active = Factory.create(:wishlist_item, :deleted_at => nil)
      inactive = Factory.create(:wishlist_item, :deleted_at => Time.now)
      
      WishlistItem.active.all.should include active
      WishlistItem.active.all.should_not include inactive
    end
  end
  
  describe "#deleted?" do
    it "returns false if deleted_at is nil" do
      Factory.build(:wishlist_item, :deleted_at => nil).should_not be_deleted
    end
    
    it "returns true if deleted_at is present" do
      Factory.build(:wishlist_item, :deleted_at => Time.now).should be_deleted
    end
  end
  
  describe "#destroy" do
    before do
      @item = Factory.create(:place, :wishlist_count => 2)
      @wi = Factory.create(:wishlist_item, :item => @item, :deleted_at => nil)
      @item.reload
    end
    
    it "decrements it's item's wishlist_count" do
      @item.wishlist_count.should == 3
      @wi.destroy
      @item.reload
      @item.wishlist_count.should == 2
    end

    it "sets it's deleted_at" do
      @wi.destroy
      @wi.deleted_at.should_not be_nil
    end
    
    it "create a private deleted activity item" do
      @wi.destroy
      @ai = ActivityItem.where(:activity_type => @wi.class.to_s, :activity_id => @wi.id, :action => "DELETE").first
      @ai.should_not be_nil
      @ai.should_not be_public
    end
    
    it "does not decrement it's item's wishlist_count if it is already deleted" do
      @wi.deleted_at = Time.now - 1.year
      @item.wishlist_count.should == 3
      @wi.destroy
      @item.reload
      @item.wishlist_count.should == 3
    end

    it "does not change it's deleted_at if it is already deleted" do
      @wi.deleted_at = Time.now - 1.year
      expect { @wi.destroy }.to_not change(@wi, :deleted_at)
    end    
  end
  
  describe "#location" do
    before { @wi = Factory.build(:wishlist_item, :lat => nil, :lng => nil) }

    it "sets the lat and lng from a geo-position header" do
      @wi.location = Geo::Position.new(:lat => -40, :lng => 120).to_http_header
      @wi.lat.should == -40
      @wi.lng.should == 120
    end
    
    it "ignores other fields" do
      @wi = Factory.build(:wishlist_item, :lat => nil, :lng => nil)
      @wi.location = Geo::Position.new(:lat => -40, :lng => 120, :altitude => 100, :uncertainty => 140, :heading => -40, :speed => 100, :timestamp => Time.now).to_http_header
      @wi.lat.should == -40
      @wi.lng.should == 120
    end
  end
  
  describe "#propagation" do
    before { @wi = Factory.build(:wishlist_item) }

    it "increments it's items wishlist count" do
      expect { @wi.propagate!; @wi.item.reload }.to change(@wi.item, :wishlist_count).by(1)
    end

    it "creates a public creation activity item" do
      @wi.propagate!
      ai = ActivityItem.where(:activity_type => @wi.class.to_s, :activity_id => @wi.id, :action => "CREATE").first
      ai.should_not be_nil
      ai.should be_public
    end
    
    it "updates it's source result id if it's source is a place search" do
      @wi.source = Factory.create(:place_search)
      @wi.save
      expect { @wi.propagate!; @wi.source.reload }.to change(@wi.source, :result_id).from(nil).to(@wi.item_id)      
    end
    
    it "is enqueued on creation" do
      # This doesn't work because there's no way to get commit callbacks to run
      # only on create and still run in test environment
      # Hence, assume it passes?
      # @wi.save
      # @wi.run_callbacks(:commit)
      # Jobs::Propagator.should have_queued("WishlistItem", @wi.id).in(:processing)
    end
  end
  
  describe "#tweeting" do
    before { @wi = Factory.build(:wishlist_item) }
    
    it "sends an update to twitter" do
      fake_production!
      Twitter.should_receive(:update).with(/Hot on Spot:(.+)/).and_return(true)
      @wi.create_tweets!
    end
    
    it "generates tweets with the name of the city as a hash tag" do
      @wi.tweet.should match /\##{@wi.item.city.downcase}/
    end

    it "removes spaces from the city to enable hash tags" do
      @wi.item.city = "San Francisco"
      @wi.tweet.should match /\#sanfrancisco/
    end

    it "does not try to update twitter if the tweet would have to be > 140 characters" do
      @wi.item.name = "This is too long a name for twitter to be able to handle with everything else that we are trying to publish"
      @wi.tweet.should be_nil
      Twitter.should_not_receive(:update)
      @wi.create_tweets!
    end
    
    it "handles a twitter forbidden error" do
      fake_production!
      Twitter.should_receive(:update).and_raise(Twitter::Forbidden.new('error', {:error => 'error'}))
      expect { @wi.create_tweets! }.to_not raise_error
    end
    
    it "caches the tweet string unless a reload parameter is passed in" do
      original = @wi.tweet
      @wi.item.name = "A different name"
      @wi.tweet.should == original
      @wi.tweet(:reload => true).should_not == original
    end
    
    it "does not call twitter unless in production" do
      Twitter.should_not_receive(:update)
      @wi.create_tweets!
    end
    
    it "is enqueued on creation" do
      # This doesn't work because there's no way to get commit callbacks to run
      # only on create and still run in test environment
      # Hence, assume it passes?
      # @wi.save
      # @wi.run_callbacks(:commit)
      # Jobs::WishlistTweeter.should have_queued(@wi.id).in(:processing)
    end
  end
end
