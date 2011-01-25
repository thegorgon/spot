require 'tempfile'
module Chomp

  class Optimizer
    YUI_COMPRESSOR_JAR = File.join(File.dirname(__FILE__), '..', '..', 'vendor', 'yahoo', 'yuicompressor', '/yuicompressor-2.4.2.jar')

    def optimize
      compile_sass if defined?(Sass::Plugin)
      clean(false)
      compress_asset_groups
      announce 'Restart Rails NOW if it is running.'
    end
  
    def clean(verbose=true)
      wipe_cache(Chomp.javascripts_cache_path, /\A\w+_[0-9a-f]{40}\.js\Z/)
      wipe_cache(Chomp.stylesheets_cache_path, /\A\w+_[0-9a-f]{40}(_ssl)?\.css\Z/)
      announce 'Restart Rails NOW if it is running.' if verbose
    end
  
    private
    
    # Safely wipe cache directory.
    def wipe_cache(path, regex)
      return unless File.directory?(path)
      okay = true
      Dir.foreach(path) do |file|
        if file =~ regex;     
          File.delete(File.join(path, file))
        elsif file != '.' && file != '..'
          announce "Unexpected file found found: #{file}"
          okay = false
        end
      end
      if okay
        Dir.rmdir(path)
      else
        announce "#{path} should only contain optimized assets."
        announce 'PLEASE CORRECT THIS PROBLEM IMMEDIATELY.'
        exit 1
      end
    end
    
    # Force Sass compilation into CSS.
    def compile_sass
      never_update = Sass::Plugin.options[:never_update]
      always_update = Sass::Plugin.options[:always_update]
      Sass::Plugin.options[:never_update] = false
      Sass::Plugin.options[:always_update] = true
      Sass::Plugin.update_stylesheets
      Sass::Plugin.options[:never_update] = never_update
      Sass::Plugin.options[:always_update] = always_update
      announce 'Compiled Sass stylesheets into CSS.'
    end

    # Compress asset groups.
    def compress_asset_groups
      FileUtils.mkdir_p(Chomp.javascripts_cache_path)
      FileUtils.mkdir_p(Chomp.stylesheets_cache_path)

      @original_count = 0
      @original_size = 0
      @optimized_count = 0
      @optimized_size = 0

      assets = Chomp::DynamicAssets.new(:javascript)
      assets.group_names.each do |name|
        files = assets.group(name)
        chomp_asset(name, files, 'js')
      end
      assets = Chomp::DynamicAssets.new(:stylesheet)
      assets.group_names.each do |name|
        files = assets.group(name)
        chomp_asset(name, files, 'css')
      end

      # announce
      savings_announce('Overall optimization: ', @original_size, @original_count, @optimized_size, @optimized_count)
    end

    # Combined all files then run YUI compressor over them, compute SHA1 of result and use for unique filename.
    def chomp_asset(name, files, ext)

      combined_data = ''
      if ext == 'js'
        files.each do |file|
          combined_data << File.read(File.join(Rails.public_path, file)) << ';'
        end
        compressed_data = compress(name, ext, combined_data)
        write_output(name, ext, compressed_data, false)
      else
        combined_data_ssl = ''
        files.each do |file|
          data = File.read(File.join(Rails.public_path, file))
          combined_data << rewrite_css_urls(file, data)
          combined_data_ssl << rewrite_css_urls(file, data, true)
        end
        compressed_data = compress(name, ext, combined_data)
        compressed_data_ssl = compress(name, ext, combined_data_ssl)
        write_output(name, ext, compressed_data, false)
        write_output(name, ext, compressed_data_ssl, true) if compressed_data_ssl != compressed_data
      end

      # update stats
      @original_count += files.size
      @original_size += combined_data.size
      @optimized_count += 1
      @optimized_size += compressed_data.size
      
      savings_announce("Optimized #{ext.upcase} asset #{name}: ", combined_data.size, files.size, compressed_data.size, 1)
    end
    
    # Do actual compression on combined data.
    def compress(name, ext, combined_data)
      combined = Tempfile.new('chomp')
      combined.write(combined_data)
      combined.close

      # compress with YUI compressor
      compressed = Tempfile.new('chomp')
      cmd = "java -jar #{YUI_COMPRESSOR_JAR} --type #{ext} -o #{compressed.path} #{combined.path}"
      raise "YUI compressor failed for #{ext} asset group #{name}, attempted to execute:\n  #{cmd}" unless system(cmd)
      compressed.open
      compressed_data = compressed.read
      compressed.close
      compressed_data
    end

    # Write out optimized assets
    def write_output(name, ext, compressed_data, secure)
      # compute SHA1 hexdigest
      sha1 = Digest::SHA1.hexdigest(compressed_data)
      optimized_filename = "#{name}_#{sha1}#{secure ? '_ssl' : ''}.#{ext}"
      announce "Computed SHA 1 of #{ext} asset #{name} as '#{sha1}'"

      # write output
      path = File.join(ext == 'js' ? Chomp.javascripts_cache_path : Chomp.stylesheets_cache_path, optimized_filename)
      File.open(path, 'w') { |f| f << compressed_data }
    end

    # Scan CSS data for url(...) references and compute public path (including asset_host if set).
    def rewrite_css_urls(css_file, css_data, secure=false)
      css_data.gsub(/url\s*\(([^\)]+)\)/) do
        source = $1.strip
        url = case source
        when %r{^[-a-z]+://} # has protocol, don't touch
          source
        when %r{^/} # absolute path
          compute_public_path(source, secure)
        else # must be relative path
          compute_public_path(File.expand_path(source, File.dirname(css_file)), secure)
        end
        "url(#{url})"
      end
    end

    def compute_public_path(url, secure=false)
      view = if secure
        @view_ssl ||= ActionView::Base.new([], {}, Chomp::FakeController.new(true))
      else
        @view ||= ActionView::Base.new([], {}, Chomp::FakeController.new(false))
      end
      view.send(:compute_public_path, url, nil) # hack - since Rails 2.x doesn't expose this method
    end

    # Make an announcment.
    def announce(message)
      puts "** [Chomp] #{message}"
    end

    # Pluralizer.
    def pluralize(count, thing)
      count == 1 ? "#{count} #{thing}" : "#{count} #{thing.pluralize}"
    end
    
    # Savings announcement.
    def savings_announce(message, original_size, original_count, result_size, result_count)
      savings = original_size > 0 ? ((100.0 * (original_size - result_size)) / original_size).round : 0
      message << pluralize(original_size, 'byte') << ', ' << pluralize(original_count, 'file') << ' => '
      message << pluralize(result_size, 'byte') << ', ' << pluralize(result_count, 'file') << ' ('
      message << savings.to_s << '% smaller)'
      announce message
    end

  end
  
  require 'action_controller/test_process'
  class FakeController
    attr_reader :request
    def initialize(secure)
      env = secure ? { 'HTTPS' => 'on' } : {}
      @request = ActionController::TestRequest.new(env)
    end
  end
  
end