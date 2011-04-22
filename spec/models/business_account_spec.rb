require 'spec_helper'

describe BusinessAccount do
  describe "#associations" do
    it "belongs to a user" do
      BusinessAccount.reflect_on_association(:user).macro.should == :belongs_to
      BusinessAccount.reflect_on_association(:user).class_name.should == User.to_s
    end
        
  end
end