require './config/boot'
require 'hoptoad_notifier/capistrano'
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
set :app_server_n,  2
set :bg_server_n,   1

ssh_options[:forward_agent] = true
default_run_options[:pty] = true

desc 'Set the target stage to "production"'
task :production do
  set :rails_env, :production
  set :stage, :production
  set :branch, :master

  app_servers = (1..app_server_n).collect { |num| "spot#{num}.ec2" }
  app_servers << "spotapi.ec2"
  role :web, *app_servers
  role :app, *app_servers
  
  role :db, app_servers.first, :primary => true

  bg_servers = (1..bg_server_n).collect { |num| "spotbg#{num}.ec2" }
  role :bg, *bg_servers
end

desc 'Set the target stage to "staging"'
task :staging do
  set :rails_env, :staging
  set :stage, :staging
  set :branch, :staging
  servers = ["spotstaging.ec2"]
  role :app, *servers
  role :web, *servers
  role :bg, *servers
  role :db,  servers.first, :primary => true
end

task :ensure_stage do
  abort "No stage specified. Run `cap production deploy` or `cap staging deploy` to set the stage." unless exists?(:stage)
end
on :start, :ensure_stage, :except => [ :staging, :production ]

# Unicorn Deploy Settings
namespace :deploy do
  task :start do
    run "sudo bluepill start unicorn"
  end
  task :stop do
    run "sudo bluepill stop unicorn"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "sudo bluepill restart unicorn"
  end
  task :cleanup, :roles => :app do
    deploy.sphinx.stop
    deploy.workers.stop
    run "if [ `readlink #{current_path}` != #{current_release} ]; then rm -rf #{current_release}; fi"
    deploy.sphinx.start
    deploy.workers.start
  end
  
  # Sphinx deploy settings
  namespace :sphinx do
    desc "Rebuild sphinx configuration"
    task :default, :roles => :bg do
      deploy.sphinx.stop
      deploy.update_code
      deploy.migrate
      deploy.sphinx.configure
      deploy.sphinx.start
      deploy.symlink
      deploy.restart
    end
    desc "Symlink db from shared"
    task :symlink, :roles => :bg do
      run "rm -fr #{release_path}/db/sphinx && ln -nfs #{shared_path}/sphinx #{release_path}/db/sphinx"
    end
    desc "Stop sphinx"
    task :stop, :roles => :bg do
      run "sudo bluepill stop sphinx"
    end
    desc "Start sphinx"
    task :start, :roles => :bg do
      run "sudo bluepill start sphinx"
    end
    desc "Rebuild sphinx configuration"
    task :configure, :roles => :bg do
      run "cd #{current_path} && sudo rake thinking_sphinx:configure RAILS_ENV=#{rails_env}"
    end
    desc "Restart sphinx"
    task :restart, :roles => :bg do
      run "sudo bluepill restart sphinx"
    end
  end
end

# Restart resque workers, simplistic version
namespace :workers do
  task :restart, :roles => :bg do
    "sudo bluepill restart workers"
  end

  task :stop, :roles => :bg do
    "sudo bluepill stop workers"
  end

  task :start, :roles => :bg do
    "sudo bluepill start workers"
  end
end

# JAMMIT Assets
namespace :assets do
  task :optimize, :roles => :web do
    send(:run, "cd #{release_path} && RAILS_ENV=#{rails_env} rake sass:update")
    send(:run, "cd #{release_path} && /usr/local/bin/jammit")
  end
end

#Log watch
namespace :logs do
  task :tail, :roles => :web do
    run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
     puts "#{channel[:host]}: #{data}"
     break if stream == :err
    end
  end
end

namespace :watch do
  task :unicorn, :roles => :web, :once => true do
    run "ps aux | grep unicorn" do |channel, stream, data|
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end
  task :revision, :roles => :web, :once => true do
    run "cd /u/app/current && cat REVISION" do |channel, stream, data|
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end
end

# Tag Deploys
after 'deploy' do
  system("git tag release-`date +%Y_%m_%d-%H%M`")
  system("git push origin master --tags")
end

# Callbacks
after 'deploy:update_code', 'assets:optimize'
before 'deploy:symlink', 'deploy:sphinx:symlink'
after 'deploy:restart', 'workers:restart'
