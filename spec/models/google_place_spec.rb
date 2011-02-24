require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GooglePlace do
  before :each do 
    @gp = Factory.build(:google_place)
  end
  it "has a numerical latitude" do
    @gp.lat = nil
    @gp.valid?.should == false
    @gp.errors[:lat].should_not be :empty?
    @gp.lat = "error"
    @gp.valid?.should == false
    @gp.errors[:lat].should_not be :empty?
  end
  it "has a numerical longitude" do
    @gp.lng = nil
    @gp.valid?.should == false
    @gp.errors[:lng].should_not be :empty?
    @gp.lng = "error"
    @gp.valid?.should == false
    @gp.errors[:lng].should_not be :empty?
  end
  it "has a unique identifier (cid)" do
    @gp.cid = nil
    @gp.valid?.should == false
    @gp.errors[:cid].should_not be :empty?
  end
  describe "parsing" do
    before :each do 
      @valid_input = {
        'url' => "http://www.google.com/maps/place?source=uds&q=*&cid=13838414429041582512",
        'titleNoFormatting' => "Tester Place",
        'streetAddress' => "1 Test Place",
        'listingType' => 'local business',
        'city' => 'Testville',
        'region' => 'California',
        'country' => 'USA',
        'addressLines' => ["1 Test Place", "Testville, CA"],
        'phoneNumbers' => [{'type' => "phone", 'number' => '555-555-5555'}],
        'lat' => '37.64532',
        'lng' => '-120.3480'
      }
    end
    it "returns nil without a cid" do
      GooglePlace.parse(@valid_input.except('url')).should == nil
      @valid_input['url'] = "http://www.google.com"
      GooglePlace.parse(@valid_input).should == nil
    end
    it "parses valid input into a valid google place record" do
      @gp = GooglePlace.parse(@valid_input)
      @gp.valid?.should == true
    end
  end
  describe "place binding" do
    before :each do
      @place = Factory.create(:place)
    end
    it "returns the existing place if one exists" do
      @gp.place = @place
      @gp.bind_to_place!.should == @place
    end
    it "creates a valid place if one does not exist" do
      @np = @gp.bind_to_place!
      @np.class.should == Place
      @np.id.should_not == @place.id
      @np.valid?.should == true
    end
  end
  describe "searching" do
    it "returns a list of valid google places" do
      @original = GooglePlace.search(:ll => "37.64532,-120.3480")
      @valid = @original.filter { |r| r.kind_of?(GooglePlace) && r.valid? }
      @results.should have_at_least(1).items
      @original.length.should == @valid.length
    end
  end
end