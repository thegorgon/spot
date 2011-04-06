require 'spec_helper'

describe Api::PlacesController do
  before { init_rails_warden! }

  describe "#index" do
    before { @places = (1..10).collect { |p| Factory.create(:place) } }
   
    it "accepts a comma separated list of place ids and responds with the places" do
      get :index, :ids => @places.map(&:id).join(',')
      json = response.body
      array = JSON.parse(json)
      array.should have(@places.length).items
      array.collect { |a| a["_type"] }.uniq.should == ["Place"]
    end
    
    it "responds with nil for place ids that don't exist" do
      get :index, :ids => [-1].join(',')
      json = response.body
      array = JSON.parse(json)
      array.should == [nil]
    end
    
    it "responds with places in the order of the ids provided" do
      ids = @places.map(&:id)
      get :index, :ids => ids.join(',')
      json = response.body
      array = JSON.parse(json)
      ids.each_with_index do |id, i|
        array[i].should_not be_nil
        array[i]["id"].should == id
      end
    end
  end
  
  describe "#search" do
    before :each do
      @params = {"query" => "Altena", "position" => Geo::Position.new(:lat => 30, :lng => -30), "ignore" => "thisparam"}
      @search = PlaceSearch.from_params!(@params)
      @place = Factory.create(:place)
      Place.should_receive(:search).any_number_of_times.and_return([@place])
    end
    
    it "passes the params onto a PlaceSearch" do
      PlaceSearch.should_receive(:from_params!).with(hash_including(@params)).and_return(@search)
      get :search, @params
    end
    
    it "should set the X-Search-ID header to the place search id" do
      PlaceSearch.should_receive(:from_params!).and_return(@search)
      get :search, @params
      response.headers["X-Search-ID"].should == @search.id.to_s
    end
    
    it "responds with an array of place json" do
      get :search, @params
      json = response.body
      array = JSON.parse(json)
      array.should have(1).items
      array.first["id"].should == @place.id
    end
  end
end