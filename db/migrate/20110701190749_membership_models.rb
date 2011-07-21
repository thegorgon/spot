class MembershipModels < ActiveRecord::Migration
  def self.up
    create_table :credit_cards do |t|
      t.integer :user_id
      t.string :cardholder_name
      t.string :token
      t.string :card_type
      t.string :bin
      t.string :last_4
      t.integer :position
      t.integer :expiration_month
      t.integer :expiration_year
      t.timestamps
    end
    add_index :credit_cards, :user_id
    add_index :credit_cards, :token, :unique => true
    
    add_column :users, :customer_id, :string
    add_index :users, :customer_id, :unique => true
    add_column :users, :city_id, :integer
    add_index :users, :city_id    
    
    create_table :memberships do |t|
      t.integer   :user_id, :null => false
      t.string    :payment_method_type, :null => false
      t.integer   :payment_method_id, :null => false
      t.integer   :city_id, :null => false
      t.integer   :status, :limit => 4, :null => false, :default => 0
      t.datetime  :expires_at
      t.datetime  :starts_at, :null => false
      t.datetime  :created_at, :null => false
    end
    add_index :memberships, :user_id
    
    create_table :membership_applications do |t|
      t.integer  :user_id, :null => false
      t.integer  :city_id, :null => false
      t.string   :referral_code, :null => false
      t.text     :survey, :null => false
      t.datetime  :approved_at
      t.timestamps
    end
    add_index :membership_applications, [:city_id, :user_id], :unique => true
    
    create_table :promo_codes do |t|
      t.string :code, :null => false
      t.integer :duration, :null => false, :default => -1
      t.integer :user_count, :null => false, :default => -1
      t.integer :use_count, :null => false, :default => 0
      t.timestamps
    end
    add_index :promo_codes, :code, :unique => true
    
    create_table :invitation_codes do |t|
      t.integer :user_id
      t.string :code, :null => false
      t.integer :invitation_count, :null => false, :default => -1
      t.integer :claimed_count, :null => false, :default => 0
      t.integer :signup_count, :null => false, :default => 0
    end
    add_index :invitation_codes, :code, :unique => true
    
    create_table :subscriptions do |t|
      t.integer   :user_id
      t.integer   :credit_card_id
      t.string    :plan_id
      t.string    :braintree_id
      t.integer   :price_cents
      t.integer   :balance_cents
      t.string    :status
      t.integer   :billing_day_of_month
      t.date      :next_billing_date
      t.date      :billing_period_start_date
      t.date      :billing_period_end_date
      t.datetime  :cancelled_at
      t.datetime  :created_at
    end
    add_index :subscriptions, :user_id
  end

  def self.down
    remove_column :users, :customer_id
    remove_column :users, :city_id

    drop_table :credit_cards
    drop_table :memberships
    drop_table :promo_codes
    drop_table :invitation_codes
    drop_table :membership_applications
    drop_table :subscriptions
  end
end
