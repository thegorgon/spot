require 'spec_helper'

describe Api::ActivityController do
  before(:all) { User.delete_all }
  before { init_rails_warden! }

  describe "#show" do
    before { Factory.create(:activity_item) }
    it "renders an activity feed" do
      get :show
      response.body.should == ActivityItem.feed.to_json
    end

    it "works if logged in" do
      login Factory.create(:user)
      get :show
      response.body.should == ActivityItem.feed.to_json
    end

    it "works if not logged in" do
      get :show
      response.body.should == ActivityItem.feed.to_json
    end

    it "passes request params onto the feed" do
      # You lose symbols through the request, so use strings
      params = {"page" => 1, "since" => (Time.now - 1.hour), "ignore" => "thisparam"}
      ActivityItem.should_receive(:feed).with(hash_including(params))
      get :show, params
    end
  end
end