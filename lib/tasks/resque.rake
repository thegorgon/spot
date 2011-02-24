require 'resque/tasks'

task "resque:setup" => :environment do
  ENV["QUEUE"] = "ts_delta,processing,images"
end