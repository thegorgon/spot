require 'spec_helper'

describe BlockedEmail do
  before { @block = Factory.build(:blocked_email) }
  it "must have an address" do
    @block.should be_valid
    @block.address = nil
    @block.should_not be_valid
  end
  
  it "must have a properly formatted address" do
    @block.should be_valid
    @block.address = "invalidemail"
    @block.should_not be_valid
  end

  describe "#blocked?" do
    it "returns true for emails that have been blocked" do
      address = Factory.next(:email)
      BlockedEmail.block!(address)
      BlockedEmail.blocked?(address).should == true
    end

    it "returns false for emails taht haven't been blocked" do
      address = Factory.next(:email)
      BlockedEmail.blocked?(address).should == false
    end
    
    it "returns true for invalid emails" do
      BlockedEmail.blocked?("invalidemail").should == true
    end
  end
end