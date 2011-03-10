# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require 'resque/server'

resque = Rack::Auth::Basic.new(Resque::Server.new) do |username, password|
  username == 'pp' && password == 'pilates!'
end

run Rack::URLMap.new(
  "/" => Spot::Application,
  "/admin/resque" => resque
)
