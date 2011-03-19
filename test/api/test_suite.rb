#!rails runner
SEARCHES = [{:position => Geo::Position.new(:lat => 37.768186, :lng => -122.429124, :timestamp => Time.now), :page => 1, :q => "Altena"},
            {:position => Geo::Position.new(:lat => 37.768186, :lng => -122.429124, :timestamp => Time.now), :page => 1, :q => "Zero Zero"}]
module Api
  class TestSuite
    include Rails.application.routes.url_helpers
    default_url_options[:host] = Rails.env.production?? "api.spot-app.com" : "api.rails.local:3000"
    
    def initialize(arguments=[])
      @arguments = {}
      arguments.each do |arg|
        key, value = arg.split('=')
        @arguments[key.to_sym] = value
      end
    end
        
    def logged_in?
      @cookie && @cookie.length > 0
    end
    
    def cookie=(value)
      @cookie ||= []
      if value && !@cookie.include?(value)
        @cookie << value
        log "Adding cookie : #{value}"
      elsif value.nil?
        log "Resetting cookie"
        @cookie = []
      end
    end
    
    def perform
      clear_user
      perform_unauthenticated
      login
      perform_search_test
      perform_wishlist_test
      perform_activity_test
      logout
      puts "\nComplete"
    end
    
    def clear_user
      log "First perform some cleanup :"
      device = Device.find_by_udid(login_credentials[:credentials][:device][:id])
      if device && device.user
        log "Device and user exist, destroy user, propagates down"
        device.user.destroy 
      elsif device
        log "Device exists, destroy it"
        device.destroy
      end
    end
    
    private
    
    def perform_unauthenticated
      log "Fetching wishlist unauthenticated"
      curb = request(api_wishlist_url(:format => :json))
      curb.http_get
      log "Unauthorized response code : #{curb.response_code} should == 401", 1
      
    end
    
    def login
      @cookie = nil
      log "Logging in"
      log "Getting nonce token"
      curb = request(new_api_sessions_url)
      curb.http_get
      json = JSON.parse(curb.body_str)
      nonce = json["nonce"]      
      log "Received nonce token : #{nonce}"
      @signed_nonce = Nonce.new(:token => nonce).digested
      log "Signed : #{@signed_nonce}"
      log "Logging in as : "
      print_hash login_credentials[:credentials]
      log "Performing Login"
      curb = request(api_sessions_url)
      curb.post_body = login_credentials.to_json
      curb.http_post
      json = JSON.parse(curb.body_str)
      log "Logged in as user : #{json["user"]["id"]} should > 0"
    end
    
    def login_credentials
      { :credentials => { 
          :device => {
            :os_id => "iPhone iOS 4.0", 
            :platform => "iphone", 
            :id => "2b6f0cc904d137be2e1730235f5664094b831186", 
            :app_version => "0.4" }, 
          :key => @signed_nonce } }
    end
    
    def print_hash(hash, level=1)
      hash.each do |name, value| 
        name = name.to_s.humanize.titlecase
        if value.kind_of?(Hash)
          log "#{name} : ", level
          print_hash(value, level + 1)
        else
          log "#{name} : #{value}", level
        end
      end
    end
    
    def log(string, level=0)
      @log_count ||= 0
      padding = [*0..level - 1].collect { '  ' }.join if level > 0
      string = "#{padding.to_s}#{string}"
      string = "\n#{string}" if @log_count > 0
      @log_count += 1
      print string
    end
    
    def perform_search_test
      SEARCHES.each do |search|
        search = search.clone.merge(:format => :json)
        start = Time.now.to_f
        position = search.delete(:position)
        log "Testing search : #{search.to_query} @#{position}"
        curb = request(search_api_places_url(search), position)
        curb.http_get
        json = JSON.parse(curb.body_str)
        log "Response : #{json.inspect}"
        log "Search Response length : #{json.length} should > 0, Duration : #{((Time.now.to_f - start) * 1000).round}ms", 1
      end
    end
    
    def perform_wishlist_test
      log "Fetching initial wishlist"
      curb = request(api_wishlist_url(:format => :json))
      curb.http_get
      json = JSON.parse(curb.body_str)
      log "Initial wishlist length : #{json.length} should == 0", 1
      test_item = Place.first
      test_params = {:item => {:item_type => test_item.class.to_s, :item_id => test_item.id, :location => "37.768186;-122.429124;120 epu=50 hdn=45 spd=15", :source_type => "PlaceSearch", :source_id => "1"}}
      log "Adding #{test_item.full_name} to wishlist"
      curb = request(api_wishlist_items_url(:format => :json))
      curb.post_body = test_params.to_json
      curb.http_post
      json = JSON.parse(curb.body_str)
      log "Response : #{json.inspect}"
      log "Added ID : #{json["id"]}", 1
      test_delete_id = json["id"]
      log "Fetching new wishlist"
      curb = request(api_wishlist_url(:format => :json))
      curb.http_get
      json = JSON.parse(curb.body_str)
      log "Wishlist length : #{json.length} should == 1", 1
      log "Wishlist : #{json.inspect}", 1      
      log "Attempting duplicate addition of #{test_item.full_name} to wishlist"
      curb = request(api_wishlist_items_url(:format => :json))
      curb.post_body = test_params.to_json
      curb.http_post
      json = JSON.parse(curb.body_str)
      log "Duplicate response code : #{curb.response_code} should == 409", 1
      log "Response : #{json}", 1
      log "Deleting #{test_item.full_name} from wishlist"
      curb = request(api_wishlist_item_url(test_delete_id, :format => :json))
      curb.http_delete
      log "Deleting Response code : #{curb.response_code} should == 200", 1
      log "Fetching final wishlist"
      curb = request(api_wishlist_url(:format => :json))
      curb.http_get
      json = JSON.parse(curb.body_str)
      log "Final wishlist length : #{json.length} should == 0", 1      
    end
    
    def perform_activity_test
      log "Requesting activity"
      position = Geo::Position.new(:lat => 37.768186, :lng => -122.429124, :timestamp => Time.now)
      curb = request(api_activity_url(:format => :json), position)
      curb.http_get
      json = JSON.parse(curb.body_str)
      log "Response : #{json}", 1
      log "Activity response Length : #{json.length} should > 0", 1
      curb = request(api_activity_url(:page => 2, :format => :json), position)
      curb.http_get
      json = JSON.parse(curb.body_str)
      log "Response (page 2): #{json}", 1
      log "Activity response Length (page 2): #{json.length} should > 0", 1
    end
    
    def logout
      log "Logging Out"
      curb = request(api_sessions_url(:format => :json))
      curb.http_delete
      log "Logged Out"      
    end
    
    def request(url, position=nil)
      Curl::Easy.new(url) do |curb|
        curb.headers["Content-Type"] = Mime::JSON.to_s
        curb.headers["Accept"] = Mime::JSON.to_s
        if @cookie.present?
          log "Sending cookies : #{@cookie.join(", ")}"
          curb.cookies = @cookie.join("\n")
        end
        curb.headers["Geo-Position"] = position.to_http_header if position
        curb.enable_cookies = true
        curb.on_progress { |dl_total, dl_now, ul_total, ul_now| print "."; true }
          
        curb.on_header do |header_data|
          key, value = header_data.split(':')
          key.strip!
          self.cookie = value.strip if key == "Set-Cookie"
          header_data.length
        end
      end
    end
  end
end

suite = Api::TestSuite.new(ARGV)
suite.perform