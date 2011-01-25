source_config_file = File.join(File.dirname(__FILE__), 'samples', 'chomp-sample.yml')
dest_config_file = File.join(File.dirname(__FILE__), '..', '..', '..', 'config', 'chomp.yml')

unless File.exists?(dest_config_file)
  puts '[Chomp] Creating sample configuration file: config/chomp.yml'
  File.open(dest_config_file, 'w') { |f| f << File.read(source_config_file) }
else
  puts '[Chomp] Existing configuration file found: config/chomp.yml'
end
