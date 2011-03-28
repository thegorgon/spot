Factory.define :blocked_email do |be|
  be.address      { Factory.next(:email) }
end
