require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Spot
  class Application < Rails::Application
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    # Set the Console Logger to STDOUT
    config.logger = Logger.new(STDOUT) if defined? Rails::Console
    config.secret = "6f0b012c7d37f3357d137b30968bc67cf61a4bc4956ddbbf1896e9ff9dba5f7ef258705a6e894c9f39998360fe857dfba18e409b8b6f5ba2164f361fe948ca9d"  
    config.active_record.observers = [:place_sweeper]
    
  end
end
