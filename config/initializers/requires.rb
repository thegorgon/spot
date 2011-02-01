Dir["#{RAILS_ROOT}/lib/**/*"].each do |patch_file|
  next if %w(. ..).include?(patch_file) || File.directory?(patch_file) || File.extname(patch_file) != ".rb"
  load patch_file
end