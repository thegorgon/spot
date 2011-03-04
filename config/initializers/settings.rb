Sass::Plugin.options[:style] = :compressed
Sass::Plugin.options[:sass2] = true
Sass::Plugin.options[:template_location] = File.join(Rails.root, 'app', 'sass')
ActiveRecord::Base.include_root_in_json = false

Tumblr.options[:config_file] = File.join(Rails.root, 'config', 'apis', 'tumblr.yml')
Flickr.options[:config_file] = File.join(Rails.root, 'config', 'apis', 'flickr.yml')
Google.options[:config_file] = File.join(Rails.root, 'config', 'apis', 'google.yml')

Paperclip::Attachment.default_options[:convert_options] = { :all => '-quality 100 -strip -colorspace RGB'}

TWITTER_SETTINGS = YAML.load_file(File.join(Rails.root, 'config', 'apis', 'twitter.yml'))['twitter']
Twitter.configure do |config|
  config.consumer_key       = TWITTER_SETTINGS['consumer_key']
  config.consumer_secret    = TWITTER_SETTINGS['consumer_secret']
  config.adapter            = :net_http
end

Twitter.send(:mattr_accessor, :oauth)
Twitter.oauth = OAuth::Consumer.new( 
  TWITTER_SETTINGS['consumer_key'], 
  TWITTER_SETTINGS['consumer_secret'], { 
    :scheme             => :header,
    :http_method        => :post,
    :site               => 'https://api.twitter.com' 
})