class Analysis
  SCOPES = [:overall, :today, :wishlist_histogram, :user_installs, :wishlist_by_date, :sessions_by_date, :actives_by_date]
  attr_accessor :overall, :today
  
  def initialize(params)
    @params = params
    @scope = params[:scope].try(:to_sym) || [:overall, :today]
    @scope.map! { |key| key.to_sym } if @scope.kind_of?(Array)
    populate
  end
  
  def include?(key)
    @scope == :all || 
    @scope == key.to_sym || 
    (@scope.kind_of?(Array) && @scope.include?(key.to_sym))
  end
  
  def populate
    SCOPES.each do |scope|
      send("populate_#{scope}") if include?(scope)
    end
  end
  
  def populate_overall
    @overall = []
    @overall << {:value => User.count, :title => "Installed Users", :id => "user_count"}
    @overall << {:value => WishlistItem.count, :title => "Wishlist Entries", :id => "wishlist_count"}
    @overall << {:value => WishlistItem.connection.execute("SELECT COUNT(DISTINCT item_type, item_id) FROM wishlist_items").entries.first.first, 
                      :title => "Places Wishlisted", :id => "wishlisted_place_count"}
  end
  
  def populate_today
    @today = []
    @today << {:value => User.where(:created_at => (Time.now.midnight..Time.now.tomorrow.midnight)).count, 
                      :title => "Installed Users", :id => "user_installs"}
    @today << {:value => WishlistItem.where(:created_at => (Time.now.midnight..Time.now.tomorrow.midnight)).count, 
                      :title => "Wishlist Entries", :id => "wishlisted_today"}
    @today << {:value => WishlistItem.connection.execute("SELECT COUNT(DISTINCT item_type, item_id) FROM wishlist_items WHERE created_at BETWEEN '#{Time.now.midnight.to_s(:db)}' AND '#{Time.now.tomorrow.midnight.to_s(:db)}'").entries.first.first, 
                      :title => "Places Wishlisted", :id => "places_today"}
  end
  
  def populate_wishlist_histogram
    result = WishlistItem.connection.execute(<<-sql 
      SELECT CAST(wishlist_size AS char), COUNT(id) AS users 
        FROM (
          SELECT COUNT(wi.id) wishlist_size, u.id id 
            FROM users u 
            LEFT JOIN wishlist_items wi 
              ON wi.user_id = u.id 
            GROUP BY id
          ) t 
        GROUP BY wishlist_size
      sql
    )
    @wishlist_histogram = {:rows => result.entries, :cols => [ {:id => "wishlist_size", :type => "string", :label => "Wishlist Size"}, 
                                                               {:id => "users", :type => "number", :label => "Users"} ]}
  end
  
  def populate_user_installs
    result = User.connection.execute(<<-sql 
      SELECT DATE(created_at) AS date, COUNT(id) AS count
        FROM users
      GROUP BY DATE(created_at)
      sql
    )
    @user_installs = {:rows => result.entries, :cols => [ {:id => "date", :type => "string", :label => "Date"},
                                                          {:id => "count", :type => "number", :label => "Install Count"} ]}
  end
  
  def populate_wishlist_by_date
    result = WishlistItem.connection.execute(<<-sql 
      SELECT DATE(created_at) AS date, COUNT(id) AS count
        FROM wishlist_items
      GROUP BY DATE(created_at)
      sql
    )
    @wishlist_by_date = {:rows => result.entries, :cols => [ {:id => "date", :type => "string", :label => "Date"},
                                                             {:id => "count", :type => "number", :label => "Wishlist Item Count"} ]}
  end
  
  def populate_sessions_by_date
    result = UserEvent.connection.execute(<<-sql 
      SELECT DATE(created_at) AS date, COUNT(id) AS count
        FROM user_events
      WHERE event_id = #{Event::API_WISHLIST_LOAD}
      GROUP BY DATE(created_at)
      sql
    )
    @sessions_by_date = {:rows => result.entries, :cols => [ {:id => "date", :type => "string", :label => "Date"},
                                                             {:id => "count", :type => "number", :label => "Opens"} ]}
  end
  
  def populate_actives_by_date
    result = UserEvent.connection.execute(<<-sql 
      SELECT DATE(created_at) AS date, COUNT(DISTINCT user_id) AS count
        FROM user_events
      WHERE event_id = #{Event::API_WISHLIST_LOAD}
      GROUP BY DATE(created_at)
      sql
    )
    @actives_by_date = {:rows => result.entries, :cols => [ {:id => "date", :type => "string", :label => "Date"},
                                                             {:id => "count", :type => "number", :label => "Users"} ]}
  end
  
  def as_json(*args)
    hash = {}
    SCOPES.each do |scope|
      result = self.instance_variable_get("@#{scope}")
      hash[scope] = result if result
    end
    hash
  end
end