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
  end
  
  describe "#salt" do
    it "sets the salt on save" do
      @account.password_salt = nil
      @account.save
      @account.password_salt.should be_present
    end

    it "resets on save when the password is changed" do
      @account.save
      @account.password_salt = "initialsalt"
      @account.password = "initialpassword"
      @account.password = "newpassword"
      expect { @account.save }.to change(@account, :password_salt)
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
end