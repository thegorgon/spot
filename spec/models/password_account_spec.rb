require 'spec_helper'

describe PasswordAccount do
  before :each do
    @account = Factory.build(:password_account)
  end
  
  describe "#validations" do
    it "must have a password" do
      @account.should be_valid
      @account.password = nil
      @account.should_not be_valid
    end

    it "must have a password between 4 and 10 characters long" do
      @account.should be_valid
      @account.password = ""
      @account.should_not be_valid
      @account.password = "abcdefghijklmnopqrstuvwxyz"
      @account.should_not be_valid
      @account.password = "password"
      @account.should be_valid
    end

    it "must have a login" do
      @account.should be_valid
      @account.login = nil
      @account.should_not be_valid
    end

    it "must have a unique login" do
      @account1 = Factory.create(:password_account, :login => "login1@login.com")
      @account2 = Factory.build(:password_account, :login => "login1@login.com")
      @account2.should_not be_valid
    end
    
    it "must has an email login" do
      @account.should be_valid
      @account.login = "notanemail"
      @account.should_not be_valid
    end  
    
    it "fails if the password is changed without an old password" do
      @account.save.should == true
      @account.password = "new_password"
      @account.save.should == false
      @account.errors[:current_password].should_not be_empty
    end  

    it "succeeds if the password is changed without an old password but with an override" do
      @account.save.should == true
      @account.password = "new_password"
      @account.override_current_password!
      @account.save.should == true
      @account.errors[:current_password].should be_empty
    end  
  end
    
  describe "#salt" do
    it "sets the salt on save" do
      @account.password_salt = nil
      @account.save
      @account.password_salt.should be_present
    end

    it "resets on save when the password is changed" do
      @account.password = "initialpassword"
      @account.save
      initialsalt = @account.password_salt
      @account.password = "newpassword"
      @account.current_password = "initialpassword"
      @account.save
      @account.password_salt.should_not == initialsalt
    end
    
    it "does not reset on save when the password is not changed" do
      @account.save
      @account.password_salt = "initialsalt"
      @account.login = "newlogin"
      @account.save
      @account.password_salt.should == "initialsalt"
    end
  end
    
  describe "#crypted_password" do
    it "is not accessible" do
      @account.attributes = {:crypted_password => "crypted_password"}
      @account.should_not be_crypted_password_changed
    end
  end
  
  describe "#user" do
    it "belongs to a user" do
      PasswordAccount.reflect_on_association(:user).macro.should == :belongs_to
      PasswordAccount.reflect_on_association(:user).class_name.should == User.to_s
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
    
    it "sets the users name fields to its name fields if the user doesnt have a name" do
      @user = Factory.create(:user, :first_name => nil, :last_name => nil)
      @account.user = @user
      @account.save
      @account.user.first_name.should == @account.first_name
      @account.user.last_name.should == @account.last_name
    end

    it "leaves the users name alone if the user has a name" do
      @user = Factory.create(:user, :first_name => "Not The", :last_name => "Same Name")
      @account.user = @user
      @account.save
      @account.user.first_name.should_not == @account.first_name
      @account.user.last_name.should_not == @account.last_name
    end
    
    it "uses a user with the same email if one exists and it is not associated with a user" do
      @account.user = nil
      @account.login = Factory.next(:email)
      @user = Factory.create(:user, :email => @account.login)
      @account.save
      @account.user_id.should == @user.id
    end
  end
    
  describe "#authenticate" do
    before :each do
      @password = "Password"
      @account = Factory.create(:password_account, :login => "login@login.com", :password => @password)
    end
    
    it "returns an account with the given login and password if one exists" do
      result = PasswordAccount.authenticate(:login => @account.login, :password => @password)
      result.should == @account
    end

    it "returns nil if an account with the given login does not exist" do
      result = PasswordAccount.authenticate(:login => "notalogin@login.com", :password => @password)
      result.should be_nil
    end

    it "returns nil if the password is incorrect" do
      result = PasswordAccount.authenticate(:login => @account.login, :password => "notapassword")
      result.should be_nil
    end
  end

  describe "#register" do
    before do 
      @login = Factory.next(:email)
      @params = { :first_name => "First", :last_name => "Last", :login => @login, :password => "password" }
    end

    it "returns an account with no errors if given valid params" do
      account = PasswordAccount.register(@params)
      account.should be_kind_of PasswordAccount
      account.valid?
      account.should be_valid
    end

    it "returns an account with the given login" do
      account = PasswordAccount.register(@params)
      account.login.should == @login
    end

    it "returns an account with the given first name" do
      account = PasswordAccount.register(@params)
      account.first_name.should == @params[:first_name]
    end

    it "returns an account with the given last name" do
      account = PasswordAccount.register(@params)
      account.last_name.should == @params[:last_name]
    end
      
    it "returns an account with errors unless given an invalid email" do
      @params[:login] = "INVALID EMAIL"
      account = PasswordAccount.register(@params)
      account.should_not be_valid
      @params[:login] = ""
      account = PasswordAccount.register(@params)
      account.should_not be_valid
      @params[:login] = nil
      account = PasswordAccount.register(@params)
      account.should_not be_valid
    end

    it "returns an account with errors unless given a name" do
      @params[:first_name] = ""
      @params[:last_name] = ""
      account = PasswordAccount.register(@params)
      account.should_not be_valid
      @params[:first_name] = nil
      @params[:last_name] = nil
      account = PasswordAccount.register(@params)
      account.should_not be_valid
    end

    it "returns an account with errors unless given a password" do
      @params[:password] = nil
      account = PasswordAccount.register(@params)
      account.should_not be_valid
      @params[:password] = ""
      account = PasswordAccount.register(@params)
      account.should_not be_valid
    end
    
    it "returns an account with errors if given an existing email with an invalid password" do
      account = PasswordAccount.create(@params)
      account.should be_valid
      @params[:password] = "badpass"
      account = PasswordAccount.register(@params)
      account.should_not be_valid
    end
    
    it "returns an existing account if given a valid login and password for an existing account" do
      registered = PasswordAccount.register(@params)
      registered.save.should == true
      reregistered = PasswordAccount.register(@params)
      reregistered.should == registered
    end
    
    it "returns an account that can be authenticated with the given login and password" do
      registered = PasswordAccount.register(@params)
      registered.save.should == true
      authenticated = PasswordAccount.authenticate(@params)
      registered.should == authenticated
    end
  end
end