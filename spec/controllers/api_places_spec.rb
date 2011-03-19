require 'spec_helper'

describe Api::PlacesController do
  before { init_rails_warden! }

  describe "#index" do
    before { @places = (1..10).collect { |p| Factory.create(:place) } }
    it "accepts a comma separated list of place ids and responds with them" do
      get :index, :ids => @places.map(&:id).join(',')
      json = response.body
      array = JSON.parse(json)
      array.should have(@places.length).items
    end
  end
  
  describe "#search" do
    before :each do
      @params = {"query" => "Altena", "position" => Geo::Position.new(:lat => 30, :lng => -30), "ignore" => "thisparam"}
      @search = PlaceSearch.from_params!(@params)
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
  end
end