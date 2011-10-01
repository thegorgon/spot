namespace :db do
  HOSTS       = { "production" => "masterdb.ec2" }
  TUNNELS     = { "production" => "spot1.ec2", "staging" => "spotstaging.ec2" }
  PRESETS     = { "places"     => "cities places google_places gowalla_places facebook_places foursquare_places yelp_places",
                  "members"    => "invitation_codes promotion_codes membership_applications users facebook_accounts password_accounts memberships subscriptions credit_cards",
                  "app"        => "wishlist_items users facebook_accounts password_accounts devices place_notes activity_items",
                  "promotions" => "businesses business_accounts promotion_templates promotion_events promotion_codes",
                  "accounts"   => "devices place_notes password_accounts facebook_accounts subscriptions credit_cards memberships activity_items wishlist_items users invitation_codes promo_codes email_subscriptions" }

  task(:sync => :environment) do
    # Constants
    # Configuration Variables
    @port       = "7768"
    @remote_env ||= (ENV['REMOTE'] || "production")
    @tables     = PRESETS[ENV['PRESET']] if ENV['PRESET']
    @tables     ||= (ENV['TABLES'] || PRESETS.values.join(' ').split(' ').uniq.join(' '))
    # Helper Variables
    db_config  = YAML.load_file("#{Rails.root}/config/database.yml")
    remote_db   = db_config[@remote_env]
    local_db    = db_config[Rails.env]
    tunnel      = TUNNELS[@remote_env]
    host        = HOSTS[@remote_env]
    # Tell the User What You're Doing
    puts "connecting to #{tunnel} and generating dump from #{host} of tables : #{@tables}"
    # Generate The Dump
    gen_cmd = "ssh #{tunnel} -p #{@port} \"mysqldump -u#{remote_db['username']} -p'#{remote_db['password']}'"
    gen_cmd << " -h#{host}" if host
    gen_cmd << " --default-character-set=utf8 -r/home/pop/spotdbsync.sql #{remote_db['database']} #{@tables}\""
    system gen_cmd
    puts 'downloading dump'
    # Secure Copy the Dump
    `scp -P #{@port} #{tunnel}:spotdbsync.sql spotdbsync.sql`
    puts 'loading dump into local db'
    # Generate the Command to Load the File into the Local DB
    load_cmd = "mysql -u#{local_db['username']} "
    load_cmd += "-p#{local_db['password']} " unless local_db['password'].blank?
    load_cmd += "-h#{local_db['host']} " unless local_db['host'].blank?
    load_cmd += "#{local_db['database']} < spotdbsync.sql"
    # Load File into Local DB
    system load_cmd
    puts 'removing local dump file'
    # Cleanup
    `rm spotdbsync.sql`
    puts 'removing remote dump file'
    `ssh #{tunnel} -p #{@port} "rm ~/spotdbsync.sql"`
  end
  
  task(:clear => :environment) do
    raise Exception.new("UM...NO!") if Rails.env.production?
    @preset = ENV['PRESET']
    @tables = PRESETS[@preset] if @preset
    @tables ||= (ENV['TABLES'] || PRESETS.values.join(' ').split(' ').uniq.join(' '))
    @tables ||= ""
    puts "About to truncate : #{@tables}"
    @tables.split(' ').each do |table| 
      cmd = "TRUNCATE #{table};"
      puts "Executing '#{cmd}'"
      ActiveRecord::Base.connection.execute(cmd)
    end
    if @preset == "accounts"
      PromotionCode.issued.map { |pc| pc.unissue! }
    end
  end
  
  task(:test_account_data => :environment) do
    raise Exception.new("UM...NO!") if Rails.env.production?
    InviteRequest::CODES.each { |code| InvitationCode.find_or_create_by_code(code) }
    pc1 = PromoCode.create(:code => "PAYPROMO", :duration => 6, :acts_as_payment => true, :name => "test", :description => "6 month act as payment")
    pc2 = PromoCode.create(:code => "PROMO", :duration => 3, :acts_as_payment => false, :name => "test", :description => "3 month doesnt as payment")
    Device.create(:udid => "74b0a4f90ca69c7038a9f445d1b1913a49a5253a", :app_version => "93", :os_id => "iOS 4.3.5", :platform => "iPhone") #(iphone bitch)
    Device.create(:udid => "c06b167458298cdb1171247db5bd619b6322d289", :app_version => "93", :os_id => "iOS 5.0", :platform => "iPhone") #(niels)
    Device.create(:udid => "34183501-EA62-5937-B5EC-5C65B43F9809", :app_version => "93", :os_id => "iOS 4.3.2", :platform => "iPhone") #(iphone bitch)
    sf = City.find_by_slug("sf")
    jesse = PasswordAccount.create(:first_name => "Jesse", :last_name => "Reiss", :login => "jessereiss@gmail.com", :password => "jreiss")
    niels = PasswordAccount.create(:first_name => "Niels", :last_name => "Gabel", :login => "ngabel@oogalabs.com", :password => "ngabel")
    julia = PasswordAccount.create(:first_name => "Julia", :last_name => "Graham", :login => "jgraham@oogalabs.com", :password => "jgraham")
    User.where(:id => [niels.user_id, julia.user_id]).update_all(:city_id => sf.id)
    payform = PaymentForm.new(:user => julia.user, :params => {:payment_method_id => pc2.id, :payment_method_type => "PromoCode"})    
    payform.save
  end
  
  task(:account_testable => :environment) do
    raise Exception.new("UM...NO!") if Rails.env.production?
    ENV["PRESET"] = "accounts"
    Rake::Task["db:clear"].invoke
    Rake::Task["db:test_account_data"].invoke
  end
  
  task(:reset => :environment) do
    raise Exception.new("UM...NO!") if Rails.env.production?
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
  end
  
  task(:prime => :environment) do
    raise Exception.new("UM...NO!") if Rails.env.production?
    Rake::Task["db:reset"].invoke
    ENV['PRESET'] = 'places'
    Rake::Task["db:sync"].invoke
  end
end
