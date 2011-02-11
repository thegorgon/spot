class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.validate_password_field = false
    c.validate_email_field = false
    c.validate_login_field = false
  end
  before_validation :reset_persistence_token, :on => :create
  
  def as_json(*args)
    options = args.extract_options!
    hash = {
      :_class => self.class.to_s,
      :id => id
    }
  end  
end