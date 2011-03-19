require 'spec_helper'

describe ExternalPlace::GooglePlace do
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
end