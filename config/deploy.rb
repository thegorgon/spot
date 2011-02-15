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
set :app_server_n,  1
set :bg_server_n,   1
set :rails_env,     'production'

ssh_options[:forward_agent] = true
default_run_options[:pty] = true

app_servers = (1..app_server_n).reject { |i| i == -1 }.collect { |num| "spot#{num}.ec2" }
app_servers.each do |server|
  role :web, server
  role :app, server
end
role :db, app_servers.first, :primary => true

bg_servers = (1..bg_server_n).reject { |i| i == -1 }.collect { |num| "spotbg#{num}.ec2" }
bg_servers.each { |server| role :bg, server }

# Passenger Deploy Settings
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
    # run "curl -s http://www.spot-app.com $2 > /dev/null"
  end
  namespace :sphinx do
    desc "Symlink db from shared"
    task :symlink, :roles => :bg do
      run "rm -fr #{release_path}/db/sphinx && ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
    end
    desc "Stop sphinx"
    task :stop, :roles => :bg do
      run "cd #{current_path} && sudo rake thinking_sphinx:stop RAILS_ENV=#{rails_env}"
    end
    desc "Start sphinx"
    task :start, :roles => :bg do
      run "cd #{current_path} && sudo rake thinking_sphinx:configure RAILS_ENV=#{rails_env} && sudo rake thinking_sphinx:start RAILS_ENV=#{rails_env}"
    end
    desc "Restart sphinx"
    task :restart, :roles => :bg do
      stop
      start
    end
  end
end

# Not working...TODO
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
before 'deploy:update_code', 'deploy:sphinx:stop'
after 'deploy:update_code', 'deploy:sphinx:symlink'
after 'deploy:update_code', 'deploy:sphinx:start'