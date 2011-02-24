require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Device do
  before :each do 
    @device = Factory.build(:device)
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
end