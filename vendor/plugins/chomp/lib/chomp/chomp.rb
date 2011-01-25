module Chomp
  VERSION = '0.4.1'
  CONFIG_FILE = File.join('config', 'chomp.yml')

  # Undefined/unknown asset group.
  class UndefinedGroupError < StandardError; end

  # Recursive asset groups are detected.
  class RecursiveGroupError < StandardError; end

  # Unable to locate optimized asset files in cache directories.
  class OptimizedAssetsNotFound < StandardError; end
  
  # Found multiple optimized assets for the same asset group.
  class DuplicateOptimizedAssetFound < StandardError; end

  # Load configuration file.
  def self.config(reload=false)
    @@config = nil if reload
    @@config ||= YAML.load_file(Rails.root.join(CONFIG_FILE))
  end

  settings = config['settings'] || {}

  # Location of the optimized javascript assets (under the public directory). Default is "javascripts/chomped"
  @@javascripts_public_dir = settings['javascripts_public_dir'] || 'javascripts/chomped'
  @@javascripts_public_dir = "/#{@@javascripts_public_dir}" unless @@javascripts_public_dir.starts_with?('/')
  mattr_reader :javascripts_public_dir
  def self.javascripts_cache_path
    File.join(Rails.public_path, javascripts_public_dir)
  end

  # Location of the optimized stylesheet assets (under the public directory). Default is "stylesheets/chomped"
  @@stylesheets_public_dir = settings['stylesheets_public_dir'] || 'stylesheets/chomped'
  @@stylesheets_public_dir = "/#{@@stylesheets_public_dir}" unless @@stylesheets_public_dir.starts_with?('/')
  mattr_reader :stylesheets_public_dir
  def self.stylesheets_cache_path
    File.join(Rails.public_path, stylesheets_public_dir)
  end
  
  # Utilize optimized content. Defaults to true if both javascript and stylesheet directory exists, false otherwise.
  @@optimized = File.directory?(javascripts_cache_path) && File.directory?(stylesheets_cache_path)
  mattr_reader :optimized

  # Dynamic assets globs are read from the configuration file when this class is instantiated.
  # Javascript and stylesheet asset group globs are lazy-evaluated, like this class itself (per-request).
  #
  class DynamicAssets

    # Create a dynamic asset group. kind must be :javascript or :stylesheet
    #
    def initialize(kind)
      raise ArgumentError, 'kind must be :javascript or :stylesheet' unless kind == :javascript || kind == :stylesheet
      @kind = kind.to_s
      config = Chomp.config(true) # reload config
      @assets = (config[@kind.pluralize] || {}).symbolize_keys!
    end

    # Return an array of asset groups found in this collection (each element in a Symbol).
    #
    def group_names
      @assets.keys
    end

    # Returns an array of asset references (Strings, like '/javascripts/application.js') for the given group (a Symbol).
    #
    def group(name, trace=[])
      recursion_check(name, trace)
      globs = @assets[name]
      raise UndefinedGroupError, "Undefined #{@kind} group '#{name}' (in #{CONFIG_FILE})" unless globs
      expand_globs(globs, trace << name)
    end

    private

    # Raise RecursiveGroupError with a helpful explanation if a recursive loop is detected.
    #
    def recursion_check(name, trace)
      index = trace.index(name)
      if index
        message = "Recursive #{@kind} group '#{name}' in #{CONFIG_FILE} ("
        trace << name
        message << trace[index..-1].join(' => ')
        message << ')'
        raise RecursiveGroupError, message
      end
    end

    # Expand glob patterns into actual file references. Glob patterns may overlap, but the file is only included once,
    # in the first matching glob (so glob pattern order is important for ordering).
    #
    def expand_globs(globs, trace)
      path = Rails.public_path
      files = []
      globs.each do |glob|
        if glob.is_a?(Symbol)
          # not a glob: include another asset group
          matches = group(glob, trace)
        else
          # glob pattern: find all matching files, without the public_path prefix, and sort alphabetically
          matches = Dir[File.join(path, glob)].each { |f| f.gsub!(path, '') }
          matches.sort!
        end
        files.concat(matches)
      end
      files.uniq!
      files.delete_if { |f| f.starts_with?(Chomp.javascripts_public_dir) || f.starts_with?(Chomp.stylesheets_public_dir) }
    end
  end

  # This class should be instantiated once per process. It caches references to all the optimized assets for the
  # request kind, either :javascript or :stylesheet.
  #
  class OptimizedJSAssets

    def initialize
      @asset = {}
      Dir.foreach(Chomp.javascripts_cache_path) do |file|
        if file =~ /\A(\w+)_[0-9a-f]{40}\.js\Z/
          name = $1.to_sym
          raise DuplicateOptimizedAssetFound, "Found duplicate optimized JS asset '#{name}'" if @asset[name]
          @asset[name] = "#{Chomp.javascripts_public_dir}/#{file}"
        end
      end
      missing = DynamicAssets.new(:javascript).group_names - @asset.keys
      raise OptimizedAssetsNotFound, "Unable to locate optimized JS asset(s): #{missing.join}" unless missing.empty?

      Rails.logger.info("** [Chomp] Located optimized JS asset(s): #{@asset.keys.join(', ')}")
    end
    
    # Return an asset file reference (String) for the given group (Symbol).
    #
    def group(name)
      asset = @asset[name]
      raise UndefinedGroupError, "Undefined JS group '#{name}'" unless asset
      asset
    end
    
  end

  class OptimizedCSSAssets
  
    def initialize
      @asset = {}
      @ssl_asset = {}
      Dir.foreach(Chomp.stylesheets_cache_path) do |file|
        if file =~ /\A(\w+)_[0-9a-f]{40}\.css\Z/
          name = $1.to_sym
          raise DuplicateOptimizedAssetFound, "Found duplicate optimized CSS asset '#{name}'" if @asset[name]
          @asset[name] = "#{Chomp.stylesheets_public_dir}/#{file}"
        elsif file =~ /\A(\w+)_[0-9a-f]{40}_ssl\.css\Z/
          name = $1.to_sym
          raise DuplicateOptimizedAssetFound, "Found duplicate optimized CSS asset (SSL) '#{name}'" if @ssl_asset[name]
          @ssl_asset[name] = "#{Chomp.stylesheets_public_dir}/#{file}"
        end
      end
      @ssl_asset.reverse_merge!(@asset)

      missing = DynamicAssets.new(:stylesheet).group_names - @asset.keys
      raise OptimizedAssetsNotFound, "Unable to locate optimized CSS asset(s): #{missing.join}" unless missing.empty?

      Rails.logger.info("** [Chomp] Located optimized CSS asset(s): #{@asset.keys.join(', ')}")
    end
    
    # Return an asset file reference (String) for the given group (Symbol).
    #
    def group(name, ssl)
      asset = ssl ? @ssl_asset[name] : @asset[name]
      raise UndefinedGroupError, "Undefined CSS group '#{name}'" unless asset
      asset
    end
    
  end
  
  
end

