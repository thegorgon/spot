namespace :s3 do
  task(:sync => :connect) do
    @source_env = (ENV['REMOTE'] || "production")
    @marker = ENV['MARKER']
    @prefix = ENV['PREFIX']
    @page_size = ENV['PAGE_SIZE'] || 1000
    page = 0
    
    source = S3_CONFIG[@source_env]['bucket']
    destination = S3_CONFIG[Rails.env]['bucket']
    puts "syncing assets from #{source} to #{destination}..."
    time = Time.now.to_i
    loop do
      assets = AWS::S3::Bucket.objects(source, :marker => @marker, :max_keys => @page_size, :prefix => @prefix)
      puts "\nsyncing page #{page += 1}, #{assets.size} assets...\n\n"
      break if assets.size == 0
      assets.each_with_index do |asset, i|
        new_key = asset.key
        puts "#{i}/#{assets.size} : Copying #{asset.key} from #{source} to #{new_key} on #{destination}"
        AWS::S3::S3Object.store(new_key, asset.value, destination, 
          :access => :public_read, :cache_control => "max-age=#{8.years.to_i}", :expires => 8.years.from_now.httpdate)
      end
      @marker = assets.last.key
    end
  end
  
  desc 'Connect to Server'
  task(:connect => :environment) do    
    AWS::S3::Base.establish_connection! S3_CONFIG[Rails.env].symbolize_keys.slice(:access_key_id, :secret_access_key)
    @bucket = AWS::S3::Bucket.find(S3_BUCKET)
  end
  
  desc 'Byte count'
  task(:bucket_size => :connect) do
    
    total_bytes = 0
    total_files = 0
    
    @bucket.each do |obj|
      puts "Size of #{obj.path}: #{obj.content_length}"
      total_bytes += obj.content_length.to_i
      total_files += 1
    end
    
    puts "Total bytes: #{total_bytes} (#{total_files} files)"
    puts "Total megs: #{total_bytes / (1024.0 * 1024.0)} (#{total_files} files)"
  end
end
