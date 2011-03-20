# encoding: utf-8

describe PlaceSearch do
  before :each do
    @position = Geo::Position.new(:lat => 30, :lng => -30, :uncertainty => 0, :timestamp => Time.now)
  end
  
  describe "#associations" do
    it "belongs to a place result" do
      PlaceSearch.reflect_on_association(:result).macro.should == :belongs_to
      PlaceSearch.reflect_on_association(:result).class_name.should == Place.to_s
    end
  end
  
  describe "#validations" do
    before { @search = Factory.build(:place_search) }

    it "has a query with at least 1 character in it" do
      @search.should be_valid
      @search.query = nil
      @search.should_not be_valid
      @search.query = ""
      @search.should_not be_valid
      @search.query = "j"
      @search.should be_valid
    end

    it "has a numerical latitude within -90 and 90" do
      @search.should be_valid
      @search.lat = -91
      @search.should_not be_valid
      @search.lat = 91
      @search.should_not be_valid
      @search.lat = 0
      @search.should be_valid
    end
    
    it "has a numerical longitude within -180 and 180" do
      @search.should be_valid
      @search.lng = -181
      @search.should_not be_valid
      @search.lng = 181
      @search.should_not be_valid
      @search.lng = 0
      @search.should be_valid
    end
  end
  
  describe "#from_params" do
    it "ignores params for undefined setters" do
      PlaceSearch.from_params(:utf8 => "utf8", :controller => "controller", :action => "action").should be_kind_of(PlaceSearch)
    end

    it "assigns param keys for keys that do have defined setters" do
      search = PlaceSearch.from_params(:page => 2, :query => "query", :position => @position)
      search.lat.should == @position.lat
      search.lng.should == @position.lng
      search.page.should == 2
      search.query.should == "query"
    end
    
    it "aliases q to query" do
      search = PlaceSearch.from_params(:q => "query")
      search.query.should == "query"
    end

    it "aliases geo_position to position" do
      search = PlaceSearch.from_params(:geo_position => @position)
      search.position.should == @position
    end
    
    it "sets the page to a reasonable value given the input" do
      search = PlaceSearch.from_params(:page => -1)
      search.page.should == 1
      search = PlaceSearch.from_params(:page => 2)
      search.page.should == 2
      search = PlaceSearch.from_params(:page => nil)
      search.page.should == 1
    end
    
    it "sets the per page to a reasonable value given the input" do
      search = PlaceSearch.from_params(:per_page => -1)
      search.per_page.should == PlaceSearch::DEFAULT_PAGE_SIZE
      search = PlaceSearch.from_params(:per_page => 20)
      search.per_page.should == 20
      search = PlaceSearch.from_params(:per_page => nil)
      search.per_page.should == PlaceSearch::DEFAULT_PAGE_SIZE
    end
    
    it "has a destructive equivalent that saves after parsing" do
      search = PlaceSearch.from_params!(:query => "query", :position => @position)
      search.should_not be_changed
      search.should_not be_new_record
    end
    
    it "has a destructive equivalent that raises errors with invalid params" do
      expect { PlaceSearch.from_params!(:query => nil, :position => @position) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
  
  describe "#position" do
    before { @search = PlaceSearch.new }

    it "accepts a header encoded geo-position string" do
      @search.position = @position.to_http_header
      @search.position.should == @position
    end

    it "accepts a geo-position object" do
      @search.position = @position
      @search.position.should == @position
    end

    it "sets the lat and lng values to the position lat and lng values" do
      @search.position = @position
      @search.lat.should == @position.lat
      @search.lng.should == @position.lng
    end
    
    it "sets the underlying database column to the header encoded geo-position string" do
      @search.position = @position.to_http_header
      @search[:position].should == @position.to_http_header
      @search.position = @position
      @search[:position].should == @position.to_http_header
    end
    
    it "returns a position object with assigned lat and lng if no position has been set, but a lat and lng have" do
      @search.lat = @position.lat
      @search.lng = @position.lng
      @search.position.lat.should == @position.lat
      @search.position.lng.should == @position.lng
    end
  end
  
  describe "#query" do
    before { @search = PlaceSearch.new; @dirty = "Küche's Bar & Grill" }

    it "sets the clean query to a cleaned value when the query is set" do
      @search.query = @dirty
      @search.cleanq.should == Geo::Cleaner.clean(:name => @dirty)
    end

    it "sets the underlying database column to the raw query" do
      @search.query = @dirty
      @search[:query].should == @dirty
    end
  end
  
  describe "#results" do
    before do
      @search = Factory.build(:place_search)
      @place = Factory.create(:place)
      Place.should_receive(:search).any_number_of_times.and_return([@place])
    end
    
    it "autoloads results" do
      @search.should_receive(:load)
      @search.results
    end
    
    it "returns an array of Result objects" do
      @search.results.should be_kind_of(Array)
      @search.results.each { |result| result.should be_kind_of(PlaceSearch::Result) }
    end
    
    it "contains place search results" do
      @search.results.map(&:place_id).should include @place.id
    end
  end
  
  describe PlaceSearch::Result do
    before do
      @place = Factory.build(:place)
      @query = "Altena"
      @result = PlaceSearch::Result.new(:place => @place, :position => @position, :query => @query)
    end

    it "delegates place methods to it's underlying place" do
      @result.image.should == @place.image
      @result.lat.should == @place.lat
      @result.lng.should == @place.lng
      @result.address_lines.should == @place.address_lines
      @result.full_address.should == @place.full_address
      @result.wishlist_count.should == @place.wishlist_count
      @result.name.should == @place.name
      @result.image_thumbnail.should == @place.image_thumbnail
      @result.to_lat_lng.should == @place.to_lat_lng
    end
    
    it "sets it's distance to the distance between the place and the given position" do
      @result.distance.should == @place.distance_to(@position)
    end

    it "sets it's relevane to the relevance between the place and the query" do
      @result.relevance.should == @place.relevance_against(@query)
    end
  end
end