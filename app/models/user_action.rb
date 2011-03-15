class UserAction < ActiveRecord::Base
  belongs_to :user
  belongs_to :action, :polymorphic => true
  
  def removed!
    touch :removed_at
  end
end