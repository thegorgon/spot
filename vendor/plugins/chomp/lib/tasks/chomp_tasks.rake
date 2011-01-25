namespace :chomp do

  desc 'Build all optimized assets'
  task :optimize => :environment do
    require 'chomp/optimizer'
    Chomp::Optimizer.new.optimize
  end
  
  desc 'Delete optimized assets'
  task :clean => :environment do
    require 'chomp/optimizer'
    Chomp::Optimizer.new.clean
  end

end