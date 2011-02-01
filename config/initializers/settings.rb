Sass::Plugin.options[:style] = :compressed
Sass::Plugin.options[:sass2] = true
Sass::Plugin.options[:template_location] = "#{Rails.root}/app/sass"
ActiveRecord::Base.include_root_in_json = false