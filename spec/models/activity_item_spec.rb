describe ActivityItem do
  describe "#associations" do
    it "belongs to a user, 'actor'" do
      ActivityItem.reflect_on_association(:actor).macro.should == :belongs_to
      ActivityItem.reflect_on_association(:actor).class_name.should == User.to_s
    end
    
    it "belongs to a polymorphic item" do
      ActivityItem.reflect_on_association(:item).macro.should == :belongs_to
      ActivityItem.reflect_on_association(:item).options[:polymorphic].should == true
    end

    it "belongs to a polymorphic activity" do
      ActivityItem.reflect_on_association(:activity).macro.should == :belongs_to
      ActivityItem.reflect_on_association(:activity).options[:polymorphic].should == true
    end
    
    it "belongs to a polymorphic source" do
      ActivityItem.reflect_on_association(:source).macro.should == :belongs_to
      ActivityItem.reflect_on_association(:source).options[:polymorphic].should == true
    end
  end

  describe "#validations" do
    before { @ai = Factory.build(:activity_item) }

    it "has a numerical latitude within -90 and 90" do
      @ai.should be_valid
      @ai.lat = -91
      @ai.should_not be_valid
      @ai.lat = 91
      @ai.should_not be_valid
      @ai.lat = 0
      @ai.should be_valid
    end
    
    it "has a numerical longitude within -180 and 180" do
      @ai.should be_valid
      @ai.lng = -181
      @ai.should_not be_valid
      @ai.lng = 181
      @ai.should_not be_valid
      @ai.lng = 0
      @ai.should be_valid
    end
    
    it "has an action which must be present and valid" do
      @ai.should be_valid
      @ai.action = nil
      @ai.should_not be_valid
      @ai.action = "InvalidAction"
      @ai.should_not be_valid
      @ai.action = ActivityItem::ACTIONS.first
      @ai.should be_valid
    end
  end
    
  describe "#feed" do
    before(:all) do
      ActivityItem.delete_all
      @origin = Geo::LatLng.new(33, -120)
      # Generate 10 items per 10 mile wide concentric ring outside the first ring and within 5 rings
      # This allows easy testing of the radial filtering
      @start = Time.now
      10.times do |i|
        4.times do |j|
          ll = Geo::LatLng.random(:within => 10 * (j + 2), :outside => 10 * (j + 1), :of => @origin)
          Factory.create(:activity_item, :lat => ll.lat, :lng => ll.lng, :created_at => @start - (j + 1).hours)
        end
      end      
    end
    
    it "accepts an origin and radius parameter that filter results to within radius miles of origin" do
      # Our record creation allows the following
      ActivityItem.feed(:origin => @origin, :radius => 10).should have(0).items 
      ActivityItem.feed(:origin => @origin, :radius => 20).should have(10).items
      ActivityItem.feed(:origin => @origin, :radius => 30).should have(20).items
    end

    it "accepts paging parameters" do
      ActivityItem.feed(:origin => @origin, :per_page => 30).should have(30).items 
      ActivityItem.feed(:origin => @origin, :per_page => 10).should have(10).items 
      ActivityItem.feed(:origin => @origin, :per_page => 50, :page => 2).should have(0).items 
      ActivityItem.feed(:origin => @origin, :per_page => 30, :page => 2).should have(10).items 
    end

    it "accepts a since date parameter that filters results to those created after the since date" do
      # Our record creation allows the following
      ActivityItem.feed(:origin => @origin, :since => @start - 1.hour).should have(0).items 
      ActivityItem.feed(:origin => @origin, :since => @start - 2.hour).should have(10).items 
      ActivityItem.feed(:origin => @origin, :since => @start - 3.hour).should have(20).items 
    end

    it "returns results sorted by creation date desc" do
      feed = ActivityItem.feed(:origin => @origin)
      sorted = feed.sort { |i1, i2| i2.created_at <=> i1.created_at }
      feed.map(&:created_at).should == sorted.map(&:created_at)
    end
  end
  
end