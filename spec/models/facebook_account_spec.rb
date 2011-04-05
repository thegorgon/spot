require 'spec_helper'

describe FacebookAccount do  
  before :each do
    @account = Factory.build(:facebook_account)
    @mock_user = Wrapr::FbGraph::User.new
    @mock_user.name = "First M. Last"
    @mock_user.first_name = "First"
    @mock_user.last_name = "Last"
    @mock_user.locale = "en_US"
    @mock_user.email = Factory.next(:email)
    @mock_user.gender = "male"
    @mock_user.id = @account.facebook_id
  end
  
  describe "#validations" do
    it "must have a facebook id" do
      @account.should be_valid
      @account.facebook_id = nil
      @account.should_not be_valid
    end

    it "must have an access token" do
      @account.should be_valid
      @account.access_token = nil
      @account.should_not be_valid
    end
        
    it "must have a properly formatted email" do
      @account.should be_valid
      @account.email = "improperlyformatted"
      @account.should_not be_valid
    end
    
    it "must have a unique facebook id" do
      @account.save
      @dupe = Factory.build(:facebook_account, :facebook_id => @account.facebook_id) 
      @dupe.should_not be_valid
    end
    
    it "must have a unique access token" do
      @account.save
      @dupe = Factory.build(:facebook_account, :access_token => @account.access_token) 
      @dupe.should_not be_valid
    end
    
    it "must have an email address" do
      @account.should be_valid
      @account.email = nil
      @account.should_not be_valid
    end
  end
  
  describe "#user" do
    it "belongs to a user" do
      FacebookAccount.reflect_on_association(:user).macro.should == :belongs_to
      FacebookAccount.reflect_on_association(:user).class_name.should == User.to_s
    end

    it "creates a user on save if not given one" do
      @account.user = nil
      @account.save
      @account.user.should_not be_nil
    end

    it "keeps the given user on save if given one" do
      @user = Factory.create(:user)
      @account.user = @user
      @account.save
      @account.user.should == @user
    end
    
    it "sets the users first name if the user does not have one" do
      @account.user = Factory.build(:user, :first_name => nil)
      @account.save
      @account.user.first_name.should_not be_nil
      @account.user.first_name.should == @account.first_name
    end

    it "sets the users first name if the user does not have one" do
      @account.user = Factory.build(:user, :last_name => nil)
      @account.save
      @account.user.last_name.should_not be_nil
      @account.user.last_name.should == @account.last_name
    end

    it "sets the users email if the user does not have one" do
      @account.user = Factory.build(:user, :email => nil)
      @account.save
      @account.user.email.should_not be_nil
      @account.user.email.should == @account.email
    end

    it "leaves the users first name if the user has one" do
      @account.user = Factory.build(:user, :first_name => "Different")
      @account.save
      @account.user.first_name.should == "Different"
    end

    it "leaves the users last name if the user has one" do
      @account.user = Factory.build(:user, :last_name => "Different")
      @account.save
      @account.user.last_name.should_not be_nil
      @account.user.last_name.should == "Different"
    end

    it "leaves the users email if the user has one" do
      @account.user = Factory.build(:user, :email => "adifferent@email.com")
      @account.save
      @account.user.email.should == "adifferent@email.com"
    end
    
    it "uses a user with the same email if one exists and it is not associated with a user" do
      @account.email = Factory.next(:email)
      @account.user = nil
      @user = Factory.create(:user, :email => @account.email)
      @account.save
      @account.user_id.should == @user.id
    end
   end
  
  describe "#authenticate" do
    before do 
      @account.save
    end

    it "returns an account with the given facebook id and access token if one exists" do      
      Wrapr::FbGraph::User.should_receive(:find).and_return(@mock_user)
      auth = FacebookAccount.authenticate(:facebook_id => @account.facebook_id, :access_token => @account.access_token)
      auth.facebook_id.should == @account.facebook_id
      auth.access_token.should == @account.access_token
    end

    it "returns a new account with the given facebook id and access token if one doesn't exist" do
      Wrapr::FbGraph::User.should_receive(:find).and_return(@mock_user)
      @mock_user.id = Factory.next(:facebook_id)
      access_token = "newaccesstoken"
      auth = FacebookAccount.authenticate(:facebook_id => @mock_user.id, :access_token => access_token)
      auth.facebook_id.should == @mock_user.id
      auth.access_token.should == access_token
    end
    
    it "returns nil without a facebook id" do
      auth = FacebookAccount.authenticate(:access_token => @account.access_token)
      auth.should be_nil
    end

    it "returns nil with no params" do
      auth = FacebookAccount.authenticate(nil)
      auth.should be_nil
    end
    
    it "returns nil without an access token" do
      auth = FacebookAccount.authenticate(:facebook_id => @account.facebook_id)
      auth.should be_nil
    end
    
    it "returns nil if facebook does not respond with an email" do
      @mock_user.email = nil
      Wrapr::FbGraph::User.should_receive(:find).and_return(@mock_user)
      auth = FacebookAccount.authenticate(:facebook_id => @account.facebook_id, :access_token => @account.access_token)
      auth.should be_nil
    end
    
    it "returns nil if facebook does not respond with the account's facebook id" do
      @mock_user.id = @account.facebook_id + 1
      Wrapr::FbGraph::User.should_receive(:find).and_return(@mock_user)
      auth = FacebookAccount.authenticate(:facebook_id => @account.facebook_id, :access_token => @account.access_token)
      auth.should be_nil
    end

    it "returns nil if facebook does not respond with a user" do
      Wrapr::FbGraph::User.should_receive(:find).and_return(nil)
      auth = FacebookAccount.authenticate(:facebook_id => @account.facebook_id, :access_token => @account.access_token)
      auth.should be_nil
    end
  end
  
  describe "#fb_user" do
    it "returns a facebook user" do
      Wrapr::FbGraph::User.should_receive(:find).with(@account.facebook_id, hash_including(:access_token => @account.access_token)).and_return(@mock_user)      
      @account.fb_user.should be_kind_of Wrapr::FbGraph::User
    end

    it "returns a facebook user with the same facebook id as the account" do
      Wrapr::FbGraph::User.should_receive(:find).with(@account.facebook_id, hash_including(:access_token => @account.access_token)).and_return(@mock_user)      
      @account.fb_user.id.to_i.should == @account.facebook_id
    end

    it "returns a facebook user with an email address" do
      Wrapr::FbGraph::User.should_receive(:find).with(@account.facebook_id, hash_including(:access_token => @account.access_token)).and_return(@mock_user)      
      @account.fb_user.email.should be_present
    end

    it "returns a facebook user with a valid email address" do
      Wrapr::FbGraph::User.should_receive(:find).with(@account.facebook_id, hash_including(:access_token => @account.access_token)).and_return(@mock_user)      
      @account.fb_user.email.should =~ EMAIL_REGEX
    end

    it "returns nil if facebook responds with a different facebook account" do
      @mock_user.id = @account.facebook_id + 1
      Wrapr::FbGraph::User.should_receive(:find).with(@account.facebook_id, hash_including(:access_token => @account.access_token)).and_return(@mock_user)      
      @account.fb_user.should be_nil
    end

    it "returns nil if facebook does not respond with an email address" do
      @mock_user.email = nil
      Wrapr::FbGraph::User.should_receive(:find).with(@account.facebook_id, hash_including(:access_token => @account.access_token)).and_return(@mock_user)      
      @account.fb_user.should be_nil
    end

    it "returns nil if facebook responds with an invalid email address" do
      @mock_user.email = "invalidaddress"
      Wrapr::FbGraph::User.should_receive(:find).with(@account.facebook_id, hash_including(:access_token => @account.access_token)).and_return(@mock_user)      
      @account.fb_user.should be_nil
    end

    it "returns nil if facebook responds with nil" do
      Wrapr::FbGraph::User.should_receive(:find).with(@account.facebook_id, hash_including(:access_token => @account.access_token)).and_return(nil)      
      @account.fb_user.should be_nil
    end
  end
  
  describe "#sync!" do
    before do 
      @account.save
    end
    
    it "returns true if the the id from facebook matches the facebook_id" do
      # Already set up mock requirement
      @mock_user.id = @account.facebook_id
      Wrapr::FbGraph::User.should_receive(:find).with(@account.facebook_id, hash_including(:access_token => @account.access_token)).and_return(@mock_user)      
      @account.sync!
    end
    
    it "updates the account to match the information from facebook" do
      @mock_user.id = @account.facebook_id
      Wrapr::FbGraph::User.should_receive(:find).with(@account.facebook_id, hash_including(:access_token => @account.access_token)).and_return(@mock_user)
      @account.sync!
      @account.first_name.should == @mock_user.first_name
      @account.last_name.should == @mock_user.last_name
      @account.name.should == @mock_user.name
      @account.locale.should == @mock_user.locale
      @account.email.should == @mock_user.email
      @account.gender.should == @mock_user.gender
    end

    it "saves the changes" do
      @mock_user.id = @account.facebook_id
      Wrapr::FbGraph::User.should_receive(:find).with(@account.facebook_id, hash_including(:access_token => @account.access_token)).and_return(@mock_user)
      @account.sync!
      @account.should_not be_changed
    end
    
    it "returns false if the id from facebook doesn't match the facebook_id" do
      @mock_user.id = @account.facebook_id + 1
      Wrapr::FbGraph::User.should_receive(:find).with(@account.facebook_id, hash_including(:access_token => @account.access_token)).and_return(@mock_user)
      @account.sync!.should == false
    end

    it "returns false if the response from facebook is nil" do
      Wrapr::FbGraph::User.should_receive(:find).with(@account.facebook_id, hash_including(:access_token => @account.access_token)).and_return(nil)
      @account.sync!.should == false
    end
    
    it "returns false if the response from facebook does not include an email" do
      @mock_user.email = nil
      Wrapr::FbGraph::User.should_receive(:find).with(@account.facebook_id, hash_including(:access_token => @account.access_token)).and_return(@mock_user)
      @account.sync!.should == false
    end

    it "returns false if the response from facebook includes an invalid email" do
      @mock_user.email = "invalid"
      Wrapr::FbGraph::User.should_receive(:find).with(@account.facebook_id, hash_including(:access_token => @account.access_token)).and_return(@mock_user)
      @account.sync!.should == false
    end
  end

end