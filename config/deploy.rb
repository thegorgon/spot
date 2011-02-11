require 'bundler/capistrano'

set :application, "Spot"
set :repository,  "git@github.com:PlacePop/spot.git"

set :scm,           "git"
set :scm_username,  'git'
set :user,          "pop"
set :branch,        "master"
set :deploy_via,    :remote_cache
set :deploy_to,     '/u/app'
set :keep_releases, 10
set :num_servers,   1
set :rails_env,     'production'

ssh_options[:forward_agent] = true
default_run_options[:pty] = true

app_servers = (1..num_servers).reject { |i| i == -1 }.collect { |num| "spot#{num}.ec2" }
app_servers.each do |server|
  role :web, server
  role :app, server
end
role :db, app_servers.first, :primary => true

# Passenger Deploy Settings
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :assets do
  task :optimize, :roles => :web do
    send(:run, "cd #{release_path} && /usr/bin/jammit config/assets.yml")
  end
end

# Tag Deploys
after 'deploy' do
  system("git tag release-`date +%Y_%m_%d-%H%M`")
  system("git push origin master --tags")
end