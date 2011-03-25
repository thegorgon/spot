# encoding: utf-8

require 'spec_helper'

describe Place do
  describe "#validations" do
    before { @place = Factory.build(:place) }

    it "has a numerical latitude within -90 and 90" do
      @place.should be_valid
      @place.lat = -91
      @place.should_not be_valid
      @place.lat = 91
      @place.should_not be_valid
      @place.lat = 0
      @place.should be_valid
    end
    
    it "has a numerical longitude within -180 and 180" do
      @place.should be_valid
      @place.lng = -181
      @place.should_not be_valid
      @place.lng = 181
      @place.should_not be_valid
      @place.lng = 0
      @place.should be_valid
    end
    
    it "has a full name" do
      @place.should be_valid
      @place.full_name = nil
      @place.should_not be_valid
    end
  end
  
  describe "#associations" do
    before :all do
      @place = Factory.create(:place)
      @undeleted = Factory.create(:wishlist_item, :item => @place, :deleted_at => nil)
      @deleted = Factory.create(:wishlist_item, :item => @place, :deleted_at => Time.now)
    end
    
    it "has many wishlist items" do
      Place.reflect_on_association(:wishlist_items).macro.should == :has_many
      Place.reflect_on_association(:wishlist_items).class_name.should == WishlistItem.to_s
    end
    
    it "ignores deleted wishlist items" do
      @place.wishlist_items.should_not include @deleted
    end
  end
  
  describe "#clean" do
    before { @place = Factory.build(:place, :clean_name => nil, :clean_address => nil) }
   
    it "autogenerates clean names and addresses on save" do
      @place.clean_name.should_not be_present
      @place.clean_address.should_not be_present
      @place.save
      @place.clean_name.should be_present
      @place.clean_address.should be_present
    end

    it "uses geo cleaning to generate clean names and address" do
      @place.clean_name.should_not be_present
      @place.clean_address.should_not be_present
      @place.save
      @place.clean_name.should == Geo::Cleaner.clean(:name => @place.full_name)
      @place.clean_address.should == Geo::Cleaner.clean(:address => @place.address)
    end    
  end
  
  describe "#canonical" do
    it "defaults to itself" do 
      @place = Factory.create(:place, :canonical_id => nil)
      @place.canonical_id.should == @place.id
    end
    
    it "is canonical only if it is itself" do
      @place = Factory.create(:place)
      @place.should be_canonical
      @place.canonical.should == @place
      @dupe = Factory.create(:place, :canonical_id => @place.id)
      @dupe.should_not be_canonical
      @dupe.canonical.should == @place
    end
    
    it "is a duplicate if it's canonical place is not itself" do
      @place = Factory.create(:place)
      @dupe = Factory.create(:place, :canonical_id => @place.id)
      @dupe.should be_duplicate
      @dupe.should_not be_canonical
    end
    
    it "can access it's duplicates" do
      @place = Factory.create(:place)
      @dupe1 = Factory.create(:place, :canonical_id => @place.id)
      @dupe2 = Factory.create(:place, :canonical_id => @place.id)
      @place.duplicates.should include(@dupe1)
      @place.duplicates.should include(@dupe2)
    end
  end
  
  describe "#processing" do
    it "enqueues an image processing job on save if an external image url has been set" do
      url = "http://www.google.com/images/logos/ps_logo2.png"
      @place = Factory.build(:place)
      @place.external_image_url = url
      @place.save
      Jobs::PlaceImageProcessor.should have_queued("Place", @place.id, :image, url).in(:images)
    end
    
    it "doesnt enqueue an image processing job if no url has been set" do
      @place = Factory.build(:place)
      @place.external_image_url = nil
      Resque.should_not_receive(:enqueue).with(Jobs::PlaceImageProcessor, any_args)
      @place.save
    end
    
    it "sets itself to be processing image when enqueueing the image job" do
      url = "http://www.google.com/images/logos/ps_logo2.png"
      @place = Factory.build(:place)
      @place.external_image_url = url
      @place.save
      @place.should be_image_processing
    end
    
    it "enqueues a deduping job on create" do
      @place = Factory.create(:place)
      Jobs::PlaceDeduper.should have_queued(@place.id).in(:processing)
    end

    it "enqueues a deduping job on update if the name or address have changed" do
      @place = Factory.create(:place)
      ResqueSpec.reset!
      @place.update_attributes(:full_name => "New Name", :full_address => "Another address")
      Jobs::PlaceDeduper.should have_queued(@place.id).in(:processing)
    end

    it "does not enqueue a deduping job on update if the name or address have not changed" do
      @place = Factory.create(:place)
      ResqueSpec.reset!
      @place.save
      Jobs::PlaceDeduper.should_not have_queued(@place.id).in(:processing)
    end
  end

  describe "#filter" do
    it "accepts a query it uses to search places" do
      @place = Factory.create(:place, :full_name => "queryable name")
      Place.should_receive(:search).with(@place.name, an_instance_of(Hash)).and_return([@place])
      Place.filter(:query => @place.name).should include @place
    end
    
    it "accepts a bitwise filter parameter and responds with an array" do
      Place.filter(:filter => 2).should be_kind_of(Array)
      Place.filter(:filter => 1).should be_kind_of(Array)
    end

    it "responds with imageless places if the filters second bit is 1" do
      @imageless = Factory.create(:place, :image_file_name => nil)
      @imaged = Factory.create(:place, :image_file_name => "/files/path/to/image.png")
      Place.filter(:filter => 2).should include @imageless
      Place.filter(:filter => 2).should_not include @imaged
    end

    it "responds with wishlisted places if the filters first bit is 1" do
      @wishlisted = Factory.create(:place)
      # Incrementing happens offline, so gotta do it with resque
      Twitter.should_receive(:update).and_return(true)
      with_resque { wi = Factory.create(:wishlist_item, :item => @wishlisted) }
      @unwishlisted = Factory.create(:place)
      Place.filter(:filter => 1).should include @wishlisted
      Place.filter(:filter => 1).should_not include @unwishlisted
    end

    it "responds with only canonical places" do
      @canonical = Factory.create(:place)
      @dupe = Factory.create(:place, :canonical_id => @canonical.id)
      Place.filter.should include @canonical
      Place.filter.should_not include @dupe
    end

    it "responds with places from newer to older" do
      10.times { Factory.create(:place) } # Start it up
      @places = Place.filter
      @sorted = @places.sort { |p1, p2| p2.id <=> p1.id }
      @places.map(&:id).should == @sorted.map(&:id)
    end
    
    it "accepts pagination parameters" do
      # Create two places
      Factory.create(:place)
      Factory.create(:place)
      @page1 = Place.filter(:page => 1, :per_page => 1)
      @page1.should have(1).items
      @page1.current_page.should == 1
      @page2 = Place.filter(:page => 2, :per_page => 1)
      @page2.should have(1).items
      @page2.current_page.should == 2
      @page_with_2 = Place.filter(:page => 1, :per_page => 2)
      @page_with_2.should have(2).items
    end
  end
  
  describe "#dedupe!" do
    it "sends all the places to DuplicatePlace deduping" do
      Place.delete_all
      10.times { Factory.create(:place) }
      DuplicatePlace.should_receive(:dedupe).exactly(Place.count).times.with(an_instance_of(Place))
      Place.dedupe!
    end
  end

  describe "#reclean!" do
    it "calls reclean on all the places when called on the class" do
      Place.delete_all
      10.times { Factory.create(:place) }
      expect { Place.reclean! }.to_not raise_error
    end
    
    it "calls clean and then save when called on an instance" do
      @place = Factory.create(:place)
      @place.should_receive(:clean).once
      @place.should_receive(:save!).once
      @place.reclean!
    end
  end
  
  describe "#relevance_against" do
    it "accepts a string query and respond with a number" do
      @place = Factory.build(:place)
      @place.relevance_against("query").should be_kind_of(Fixnum)
    end

    it "returns a higher number for a place whose name equals the query" do
      query = "query place name"
      @place1 = Factory.build(:place, :full_name => query)
      @place2 = Factory.build(:place, :full_name => "Something Else")
      @place1.relevance_against(query).should > @place2.relevance_against(query)
    end

    it "returns a higher number for the place who's city is in the query if two places have the same name" do
      query = "starbucks san francisco"
      @place1 = Factory.build(:place, :full_name => "Starbucks", :city => "San Francisco")
      @place2 = Factory.build(:place, :full_name => "Starbucks", :city => "Atlanta")
      @place1.relevance_against(query).should > @place2.relevance_against(query)
    end

    it "ignores query word order" do
      @place = Factory.build(:place, :full_name => "Ron Burgundy", :city => "San Francisco")
      relevance1 = @place.relevance_against("ron burgundy san francisco")
      relevance2 = @place.relevance_against("burgundy francisco san ron")
      relevance2.should == relevance1
    end

    it "returns 100 for a perfect match of '\#{name} \#{city}' downcased" do
      @place = Factory.build(:place, :full_name => "Altena", :city => "San Francisco")
      @place.relevance_against("altena san francisco").should == 100
    end
    
    it "ignores special characters" do
      @place = Factory.build(:place, :full_name => "John's & Joe's", :city => "München")
      @place.relevance_against("johns joes munchen").should == 100
    end
    
    it "matches lowercase capitalization" do
      @place = Factory.build(:place, :full_name => "JOHNATHAN", :city => "SF")
      @place.relevance_against("johnathan sf").should == 100
    end    
  end

  describe "#images" do
    it "resets the image if an external url is set" do
      @place = Factory.build(:place, :image_file_name => "/path/to/file.png")
      @place.attachment_for(:image).should_receive(:exists?).any_number_of_times.and_return(true)      
      @place.external_image_url = "something/new.png"
      @place.image_file_name.should be_nil
      @place = Factory.build(:place, :image_file_name => "/path/to/file.png")
      @place.external_image_url = nil
      @place.image_file_name.should_not be_nil
    end
    
    it "resets the image attribution when set to nil" do
      @place = Factory.build(:place, :image_attribution => {:key => :value})
      @place.image = nil
      @place.image_attribution.should be_nil
    end

    it "sets image processing to false when set to nil" do
      @place = Factory.build(:place, :image_processing => true)
      @place.image = nil
      @place.image_processing.should == false
    end
  end
  
  describe "#aliases" do
    it "aliases name to full_name" do
      @place = Factory.build(:place, :full_name => "Old Name")
      @place.name.should == @place.full_name
      @place.name = "New Name"
      @place.full_name.should == "New Name"
      @place.name.should == @place.full_name
    end    
  end
  
  describe "#address_lines" do
    it "returns an array of the full address lines" do
      @place = Factory.build(:place, :full_address => "1 Street\nCity, State Zip")
      @place.address_lines.should == ["1 Street", "City, State Zip"]
    end
    
    it "sets the full address to the string version of the array when given an array" do
      @place = Factory.build(:place)
      @place.address_lines = ["1 Street", "City, State Zip"]
      @place.full_address.should == "1 Street\nCity, State Zip"
    end
    
    it "handles a hash with integer like keys as though it were an array" do
      @place = Factory.build(:place)
      @place.address_lines = {"0" => "1 Street", "1" => "City, State Zip"}
      @place.full_address.should == "1 Street\nCity, State Zip"
    end
    
    it "can be displayed as 'address' which joins the lines with a ," do
      @place = Factory.build(:place)
      @place.address_lines = {"0" => "1 Street", "1" => "City, State Zip"}
      @place.address.should == "1 Street, City, State Zip"
    end
  end
  
  describe "#region_abbr" do
    it "returns the lowercase abbreviated version of a state" do
      @place = Factory.build(:place, :region => "California")
      @place.region_abbr.should == "ca"
    end

    it "returns the full region if the region is not a state" do
      @place = Factory.build(:place, :region => "region")
      @place.region_abbr.should == "region"
    end

    it "returns the abbreviated region if the region is already abbreviated" do
      @place = Factory.build(:place, :region => "CA")
      @place.region_abbr.should == "CA"
    end
  end

  describe "#external_places" do
    before :each do
      @place = Factory.create(:place) 
      @google = Factory.create(:google_place, :place => @place)
      @gowalla = Factory.create(:gowalla_place, :place => @place)
      @yelp = Factory.create(:yelp_place, :place => @place)
      @foursquare = Factory.create(:foursquare_place, :place => @place)
      @facebook = Factory.create(:facebook_place, :place => @place)
    end
    
    it "returns a list of places from external sources associated with this place" do
      @place.external_places.should include @google
      @place.external_places.should include @gowalla
      @place.external_places.should include @yelp
      @place.external_places.should include @foursquare
      @place.external_places.should include @facebook
    end
    
    it "looks up a place from a specific external source by symbol" do
      @place.external_place(:google).should == @google
      @place.external_place(:gowalla).should == @gowalla
      @place.external_place(:yelp).should == @yelp
      @place.external_place(:foursquare).should == @foursquare
      @place.external_place(:facebook).should == @facebook
    end    
  end
end