namespace :db do
  task(:sync => :environment) do
    # Constants
    HOSTS       = { "production" => "masterdb.ec2" }
    TUNNELS     = { "production" => "spot1.ec2" }
    PRESETS     = { "places"     => "places google_places gowalla_places facebook_places foursquare_places yelp_places",
                    "wishlists"  => "places wishlist_items users devices"}
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
    gen_cmd = "ssh #{tunnel} -p #{@port} \"mysqldump -u#{remote_db['username']} " + 
                                      "-p'#{remote_db['password']}' -h#{host} --default-character-set=utf8 " +
                                      "-r/home/pop/spotdbsync.sql #{remote_db['database']} #{@tables}\""
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
  
  task(:reset => :environment) do
    unless Rails.env.production?
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      Rake::Task["db:migrate"].invoke
    end
  end
  
  task(:prime => :environment) do
    unless Rails.env.production?
      Rake::Task["db:reset"].invoke
      ENV['PRESET'] = 'places'
      Rake::Task["db:sync"].invoke
    end
  end
end
