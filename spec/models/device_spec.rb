require 'spec_helper'

describe Device do
  before :each do 
    @device = Factory.build(:device)
  end
  
  it "belongs to a user" do
    Device.reflect_on_association(:user).macro.should == :belongs_to
    Device.reflect_on_association(:user).class_name.should == User.to_s
  end

  it "must have a universal device identifier" do
    @device.udid = nil
    @device.valid?.should == false
    @device.errors[:udid].should_not be :empty?
  end

  it "must have an application version" do
    @device.app_version = nil
    @device.valid?.should == false
    @device.errors[:app_version].should_not be :empty?    
  end

  it "must have an operating system identifier" do
    @device.os_id = nil
    @device.valid?.should == false
    @device.errors[:os_id].should_not be :empty?    
  end

  it "must have a platform" do
    @device.platform = nil
    @device.valid?.should == false
    @device.errors[:platform].should_not be :empty?
  end

  it "is associated with a user" do
    @user = Factory.create(:user)
    @device.user = @user
    @device.save!
    @device.user.should == @user
  end

  it "creates a user if one does not exist" do
    @device.user = nil
    @device.save!
    @device.user.should_not be :nil?
  end

  describe "#authenticate" do
    before :each do 
      @device = Factory.create(:device, :app_version => "1.0", :os_id => "iPhone 4.0")
    end
    
    it "returns the device when given the proper udid" do
      found = Device.authenticate(:device => {:id => @device.udid})
      found.should == @device
    end
    
    it "returns a new device if given a nonexistent udid and valid params" do
      found = Device.authenticate(:device => {:id => "fakeudid", :app_version => "1.0", :os_id => "iPhone 4.0", :platform => "iPhone"})
      found.should be_valid
      found.class.should == Device
      found.udid.should == "fakeudid"
    end
    
    it "returns an invalid device if given a nonexistent udid and invalid params" do
      found = Device.authenticate(:device => {:id => "fakeudid"})
      found.should_not be_valid
    end
    
    it "should update the device attributes" do    
      found = Device.authenticate(:device => {:id => @device.udid, :app_version => "1.1", :os_id => "iPhone 5.0"})
      found.app_version.should == "1.1"
      found.os_id.should == "iPhone 5.0"
    end
  end
  
  describe "#bind_to!" do
    before :each do 
      @user = Factory.create(:user)
      @device = Factory.create(:device, :user => @user)
      @new_user = Factory.create(:user)
    end
    
    it "does nothing if the new user is equal to the current user" do
      @device.bind_to!(@user)
      @device.user.should == @user
    end
    
    it "merges the new user into the old user if there is a user and the new user is different" do
      @device.bind_to!(@new_user)
      @device.user.should == @user
      @new_user.should be_destroyed
    end
    
    it "sets the user to the new user if it does not have a user" do
      new_device = Factory.build(:device, :user => nil)
      new_device.bind_to!(@new_user)
      new_device.user.should == @new_user
    end    
  
    it "saves any changes made" do
      new_device = Factory.build(:device, :user => nil)
      new_device.bind_to!(@new_user)
      new_device.should_not be_changed
    end
  end
end