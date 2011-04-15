require 'yajl/json_gem'
Dir["#{Rails.root}/lib/**/*.rb"].each { |file| require file }
Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }
require 'event' #load event to check duplicate events
