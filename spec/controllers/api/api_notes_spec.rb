require 'spec_helper'

describe Api::NotesController do
  before { init_rails_warden! }
  before :all do
    @user1 = User.first || Factory.create(:user)
    @user2 = User.offset(1).first || Factory.create(:user)
    @place1 = Factory.create(:place)
    @place2 = Factory.create(:place)
  end
  
  describe "#create" do    
    it "responds with 401 if not logged in" do
      post :create
      response.status.should == 401
    end

    it "responds with the note if the params are valid" do
      login @user1
      post :create, {:note => { :user_id => @user1.id, 
                                :place_id => @place1.id, 
                                :content => "This place is great" }}
      response.status.should == 200
      hash = JSON.parse(response.body)
      hash["id"].should == @user1.notes.last.id
    end

    it "responds with 409 if the user in the params does not match the logged in user" do
      login @user1
      post :create, {:note => { :user_id => @user2.id, 
                                :place_id => @place1.id, 
                                :content => "This place is great" }}
      response.status.should == 409
    end

    it "responds with 403 if the params are invalid" do
      login @user1
      post :create, {:note => {:user_id => @user1.id}}
      response.status.should == 403
    end    
  end
  
  describe "#index" do
    before :all do
      3.times do |i|
        Factory.create(:place_note, :user => @user1, :place => @place1)
        Factory.create(:place_note, :user => @user2, :place => @place1)
        Factory.create(:place_note, :user => @user1, :place => @place2)
        Factory.create(:place_note, :user => @user2, :place => @place2)
        Factory.create(:place_note, :user => @user1, :place => @place1, :status_flags => ["private"])
        Factory.create(:place_note, :user => @user2, :place => @place1, :status_flags => ["private"])
        Factory.create(:place_note, :user => @user1, :place => @place2, :status_flags => ["private"])
        Factory.create(:place_note, :user => @user2, :place => @place2, :status_flags => ["private"])
        note = Factory.build(:place_note, :user => @user1, :place => @place1)
        note.muted = true
        note.save
        note = Factory.build(:place_note, :user => @user2, :place => @place1)
        note.muted = true
        note.save        
        note = Factory.build(:place_note, :user => @user1, :place => @place2)
        note.muted = true
        note.save
        note = Factory.build(:place_note, :user => @user2, :place => @place2)
        note.muted = true
        note.save
        note = Factory.create(:place_note, :user => @user1, :place => @place1)
        note.destroy
        note = Factory.create(:place_note, :user => @user2, :place => @place1)
        note.destroy
        note = Factory.create(:place_note, :user => @user1, :place => @place2)
        note.destroy
        note = Factory.create(:place_note, :user => @user2, :place => @place2)
        note.destroy
      end
      
    end
    
    it "responds with 401 if not logged in" do
      get :index
      response.status.should == 401
    end
    
    it "responds with place notes if a place id is provided" do
      login @user1
      get :index, :place_id => @place1.id
      places = JSON.parse(response.body)
      places.each do |p| 
        p["place_id"].should == @place1.id
      end
    end

    it "responds with user notes if a user id is provided" do
      login @user1
      get :index, :user_id => @user1.id
      places = JSON.parse(response.body)
      places.each do |p| 
        p["user"]["id"].should == @user1.id
      end
    end

    it "responds with only public unmuted notes" do
      login @user1
      get :index, :user_id => @user1.id
      places = JSON.parse(response.body)
      places.each do |p| 
        p["status_flags"].index("private").should be_nil
        p["status_flags"].index("muted").should be_nil
      end
    end    
  end

  describe "#show" do
    before :all do
      @note = Factory.create(:place_note, :user => @user1, :place => @place1)
    end
    
    it "responds with 401 if not logged in" do
      get :show, :id => @note.id
      response.status.should == 401
    end

    it "responds with 404 if given an invalid id" do
      login @user1
      get :show, :id => -1
      response.status.should == 404
    end
    
    it "responds with the note" do
      login @user1
      get :show, :id => @note.id
      hash = JSON.parse(response.body)
      hash["id"].should == @note.id
    end
  end
  
  describe "#update" do
    before :all do
      @note = Factory.create(:place_note, :user => @user1, :place => @place1)
    end
    
    it "responds with 401 if not logged in" do
      put :update, :id => @note.id, :note => {}
      response.status.should == 401
    end
    
    it "responds with 404 if not logged in as the note owner" do
      login @user2
      put :update, :id => @note.id, :note => {:status_flags => ["private"]}
      response.status.should == 404
    end

    it "responds with 404 if given an invalid id" do
      login @user1
      put :update, :id => -1
      response.status.should == 404
    end
    
    it "responds with 404 if the note is deleted" do
      login @user1
      deleted = Factory.create(:place_note, :user => @user1, :place => @place1)
      deleted.destroy
      put :update, :id => deleted.id
      response.status.should == 404
    end
    
    it "responds with the note" do
      login @user1
      put :update, :id => @note.id, :note => {:status_flags => ["private"]}
      hash = JSON.parse(response.body)
      hash["id"].should == @note.id
    end
    
    it "updates the note" do
      login @user1
      @note.update_attribute(:status_flags, [])
      put :update, :id => @note.id, :note => {:status_flags => ["private"]}
      @note.reload
      @note.status_flags.should == ["private"]
    end
    
    it "does not update the user_id" do
      login @user1
      @note.user = @user1
      @note.save
      put :update, :id => @note.id, :note => {:user_id => @user2.id}
      @note.reload
      @note.user.should == @user1
    end

    it "does not update the place_id" do
      login @user1
      @note.place = @place1
      @note.save
      put :update, :id => @note.id, :note => {:place_id => @place2.id}
      @note.reload
      @note.place.should == @place1
    end

    it "does not update the muted status flag" do
      login @user1
      @note.muted = true
      @note.save
      put :update, :id => @note.id, :note => {:status_flags => []}
      @note.reload
      @note.should be_muted
    end

    it "does not update deleted date" do
      login @user1
      @note.deleted_at = nil
      @note.save
      put :update, :id => @note.id, :note => {:deleted_at => Time.now}
      @note.reload
      @note.deleted_at.should be_nil
    end    
  end
  
  describe "#destroy" do
    before :all do
      @note = Factory.create(:place_note, :user => @user1, :place => @place1)
    end
    
    it "responds with 401 if not logged in" do
      delete :destroy, :id => @note.id
      response.status.should == 401
    end
    
    it "responds with 404 if not logged in as the note owner" do
      login @user2
      delete :destroy, :id => @note.id
      response.status.should == 404
    end
    
    it "responds with 404 if the note is deleted" do
      login @user1
      deleted = Factory.create(:place_note, :user => @user1, :place => @place1)
      deleted.destroy
      delete :destroy, :id => deleted.id
      response.status.should == 404
    end
    
    it "responds with 404 if given an invalid id" do
      login @user1
      delete :destroy, :id => -1
      response.status.should == 404
    end
    
    it "deletes the note" do
      login @user1
      delete :destroy, :id => @note.id
      PlaceNote.find_by_id(@note.id).should be_deleted
    end
  end
end