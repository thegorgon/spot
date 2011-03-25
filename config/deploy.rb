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
    "sudo bluepill restart resque"
  end
end

# JAMMIT Assets
namespace :assets do
  task :optimize, :roles => :web do
    send(:run, "cd #{release_path} && /usr/local/bin/jammit")
  end
end

#Log watch
namespace :logs do
  task :tail, :roles => :web do
    run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
     puts # for an extra line break before the host name
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