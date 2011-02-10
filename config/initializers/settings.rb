Sass::Plugin.options[:style] = :compressed
Sass::Plugin.options[:sass2] = true
Sass::Plugin.options[:template_location] = File.join(Rails.root, 'app', 'sass')
ActiveRecord::Base.include_root_in_json = false

Tumblr.options[:config_file] = File.join(Rails.root, 'config', 'apis', 'tumblr.yml')
Flickr.options[:config_file] = File.join(Rails.root, 'config', 'apis', 'flickr.yml')
Google.options[:config_file] = File.join(Rails.root, 'config', 'apis', 'google.yml')