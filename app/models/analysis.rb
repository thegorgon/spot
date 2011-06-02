class Analysis
  class Chart < Struct.new(:title, :type, :scope); end
  SCOPES = [:overall, :today, :wishlist_histogram, :user_installs, 
              :wishlist_by_date, :sessions_by_date, :actives_by_date, :version_breakdown]
  CHARTS = [
    Chart.new("User Installs By Date", "LineChart", "user_installs"),
    Chart.new("Wishlist Items By Date", "LineChart", "wishlist_by_date"),
    Chart.new("App Opens By Date", "LineChart", "sessions_by_date"),
    Chart.new("Active Users By Date", "LineChart", "actives_by_date"),
    Chart.new("Wishlist Size Distribution", "ColumnChart", "wishlist_histogram"),
    Chart.new("App Version Breakdown", "PieChart", "version_breakdown")
  ]

  attr_accessor :overall, :today, :start, :end, :title
  
  def initialize(params)
    @params = params
    @scope = params[:scope].try(:to_sym) || [:overall, :today]
    @scope.map! { |key| key.to_sym } if @scope.kind_of?(Array)
    set_range(params[:range]) if params[:range]    
    @start = Time.parse(params[:since]) if params[:since]
    @start ||= Time.at(0)
    @start = @start.at_midnight
    @end = Time.parse(params[:until]) if params[:until]
    @end ||= (Time.now + 1.day).at_midnight
    @end = @end.at_midnight
    populate
  end
  
  def set_range(range)
    @range = range
    case range.to_sym
    when :week
      @title = "This Week"
      @start = (Time.now - 1.week).at_midnight
    when :month
      @title = "This Month"
      @start = (Time.now - 1.month).at_midnight
    else
      @title = "Overall"
    end
  end
  
  def date_range
    (@start..@end)
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
    @overall << {:value => User.where(:created_at => date_range).count, :title => "Installed Users", :id => "user_count"}
    @overall << {:value => WishlistItem.where(:created_at => date_range).count, :title => "Wishlist Entries", :id => "wishlist_count"}
    @overall << {:value => WishlistItem.connection.execute("SELECT COUNT(DISTINCT item_type, item_id) FROM wishlist_items WHERE created_at BETWEEN '#{@start.to_s(:db)}' AND '#{@end.to_s(:db)}'").entries.first.first, 
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
            WHERE u.created_at BETWEEN '#{@start.to_s(:db)}' AND '#{@end.to_s(:db)}'
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
      SELECT DATE_FORMAT(DATE(created_at), '%a %c/%e') AS date, COUNT(id) AS count
        FROM users
      WHERE created_at BETWEEN '#{@start.to_s(:db)}' AND '#{@end.to_s(:db)}'
      GROUP BY DATE(created_at)
      sql
    )
    @user_installs = {:rows => result.entries, :cols => [ {:id => "date", :type => "string", :label => "Date"},
                                                          {:id => "count", :type => "number", :label => "Install Count"} ]}
  end
  
  def populate_wishlist_by_date
    result = WishlistItem.connection.execute(<<-sql 
      SELECT DATE_FORMAT(DATE(created_at), '%a %c/%e') AS date, COUNT(id) AS count
        FROM wishlist_items
      WHERE created_at BETWEEN '#{@start.to_s(:db)}' AND '#{@end.to_s(:db)}'
      GROUP BY DATE(created_at)
      sql
    )
    @wishlist_by_date = {:rows => result.entries, :cols => [ {:id => "date", :type => "string", :label => "Date"},
                                                             {:id => "count", :type => "number", :label => "Wishlist Item Count"} ]}
  end
  
  def populate_sessions_by_date
    result = UserEvent.connection.execute(<<-sql 
      SELECT DATE_FORMAT(DATE(created_at), '%a %c/%e') AS date, COUNT(id) AS count
        FROM user_events
      WHERE event_id = #{Event::API_WISHLIST_LOAD}
        AND created_at BETWEEN '#{@start.to_s(:db)}' AND '#{@end.to_s(:db)}'
      GROUP BY DATE(created_at)
      sql
    )
    @sessions_by_date = {:rows => result.entries, :cols => [ {:id => "date", :type => "string", :label => "Date"},
                                                             {:id => "count", :type => "number", :label => "Opens"} ]}
  end
  
  def populate_actives_by_date
    result = UserEvent.connection.execute(<<-sql 
      SELECT DATE_FORMAT(DATE(created_at), '%a %c/%e') AS date, COUNT(DISTINCT user_id) AS count
        FROM user_events
      WHERE event_id = #{Event::API_WISHLIST_LOAD}
        AND created_at BETWEEN '#{@start.to_s(:db)}' AND '#{@end.to_s(:db)}'
      GROUP BY DATE(created_at)
      sql
    )
    @actives_by_date = {:rows => result.entries, :cols => [ {:id => "date", :type => "string", :label => "Date"},
                                                             {:id => "count", :type => "number", :label => "Users"} ]}
  end
  
  def populate_version_breakdown
    result = Device.connection.execute(<<-sql 
      SELECT app_version, COUNT(id) AS count
        FROM devices
      WHERE created_at BETWEEN '#{@start.to_s(:db)}' AND '#{@end.to_s(:db)}'
      GROUP BY app_version
      sql
    )
    @version_breakdown = {:rows => result.entries, :cols => [ {:id => "app_version", :type => "string", :label => "Version"},
                                                              {:id => "count", :type => "number", :label => "Devices"} ]}
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