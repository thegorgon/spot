# MANUALLY START UNICORN:
# unicorn -Dc /u/app/current/config/unicorn.rb -E production

shared_dir = '/u/app/shared'
pid_dir    = "#{shared_dir}/pids"
log_file   = "#{shared_dir}/log/unicorn.log"

runuser  = 'pop'
rungroup = 'pop'

# Workers and 1 master
worker_processes 6

# Set working directory
working_directory "/u/app/current/"

# Preload app for blazin' spawn times
preload_app true

# Restart any workers that haven't responded in n seconds
timeout 20

# Listen on a Unix data socket
listen "#{shared_dir}/tmp/unicorn.sock", :backlog => 1024

# Logging woooo
FileUtils.touch(log_file)
logger Logger.new(log_file)

pid "#{pid_dir}/unicorn.pid"

# REE: http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.
  old_pid = "#{pid_dir}/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      STDOUT.puts "Quitting PID : #{old_pid} from server #{server.pid}"
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  # Unicorn master loads the app then forks off workers - because of the way
  # Unix forking works, we need to make sure we aren't using any of the parent's
  # sockets, e.g. db connection
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
  Redis.connect if defined?(Redis)
  # Unicorn master is started as root, which is fine, but let's
  # drop the workers to specified user and group
  begin
    uid, gid = Process.euid, Process.egid
    user, group = runuser, rungroup
    target_uid = Etc.getpwnam(user).uid
    target_gid = Etc.getgrnam(group).gid
    worker.tmp.chown(target_uid, target_gid)
    if uid != target_uid || gid != target_gid
      Process.initgroups(user, target_gid)
      Process::GID.change_privilege(target_gid)
      Process::UID.change_privilege(target_uid)
    end
  rescue => e
    if RAILS_ENV == 'development'
      STDERR.puts "couldn't change user, oh well"
    else
      raise e
    end
  end
end