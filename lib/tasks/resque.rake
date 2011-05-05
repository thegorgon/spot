require 'resque/tasks'

task "resque:setup" => :environment do
  ENV["QUEUE"] = "images,ts_delta,processing"
end