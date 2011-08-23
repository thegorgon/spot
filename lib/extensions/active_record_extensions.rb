module ActiveRecordExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
    base.send(:before_save, :set_commit_flags)
    base.send(:after_commit, :clear_commit_flags)
  end
  
  module InstanceMethods
    def set_commit_flags
      @_new_commit = new_record?
      @_commits = changes
    end
    
    def clear_commit_flags
      @_new_commit = false
      @_commits = HashWithIndifferentAccess.new
    end
    
    def attribute_commited?(a)
      @_commits.has_key?(a)
    end
    
    def attribute_before_commit(a)
      attribute_commited?(a) ? @_commits[a].first : nil
    end
    
    def new_commit?
      !!@_new_commit
    end
  end
  
  module ClassMethods
    def has_acquisition_source(options={})
      belongs_to :acquisition_source
      before_create :set_acquisition_source
      define_method :set_acquisition_source do
        self.acquisition_source_id ||= Thread.current[:acquisition_source_id]
      end

      if options[:count].present?
        after_create :count_acquisition
        define_method :count_acquisition do
          if options[:count].kind_of?(Proc)
            options[:count].call(self)
          else
            acquisition_source.try("#{options[:count]}!")
          end
        end
      end      
    end
    
    def setting_flags(flags, options={})
      attribute = options[:attr] || "settings"
      inverse_attr = options[:inverse_attr]
      field = options[:field] || "setting_flags"
      protected_flags = options[:protected] || []
      scope :with_setting, lambda { |s| where(PlaceNote.with_setting_sql(s)) }
      scope :without_setting, lambda { |s| where(PlaceNote.without_setting_sql(s)) }
      
      singleton_class.instance_eval do
        define_method(:with_setting_sql) do |s|
          "(#{field} & #{1 << flags.index(s)}) > 0"
        end

        define_method(:without_setting_sql) do |s|
          "(#{field} & #{1 << flags.index(s)}) = 0"
        end
      end
      
      define_method "#{attribute}=" do |value|
        (flags & value.to_a).each do |setting|
          unless protected_flags.include?(setting)
            send("#{options[:method_prefix]}#{setting}=", true) if respond_to?("#{options[:method_prefix]}#{setting}=")
          end
        end
        (flags - value.to_a).each do |setting|
          unless protected_flags.include?(setting)
            send("#{options[:method_prefix]}#{setting}=", false) if respond_to?("#{options[:method_prefix]}#{setting}=")
          end
        end
      end

      define_method "#{attribute}" do
        settings = []
        flags.each do |flag|
          settings << flag if send("#{options[:method_prefix]}#{flag}?")
        end
        settings
      end
      
      if inverse_attr
        define_method "#{inverse_attr}=" do |value|
          (flags & value.to_a).each do |setting|
            unless protected_flags.include?(setting)
              send("#{options[:method_prefix]}#{setting}=", false) if respond_to?("#{options[:method_prefix]}#{setting}=")
            end
          end
          (flags - value.to_a).each do |setting|
            unless protected_flags.include?(setting)
              send("#{options[:method_prefix]}#{setting}=", true) if respond_to?("#{options[:method_prefix]}#{setting}=")
            end
          end
        end
        
        define_method "#{inverse_attr}" do
          settings = []
          flags.each do |flag|
            settings << flag unless send("#{options[:method_prefix]}#{flag}?")
          end
          settings
        end
      end

      flags.each_with_index do |flag, i|
        define_method("#{options[:method_prefix]}#{flag}=") do |value|
          if (value && (!value.respond_to?(:to_i) || value.to_i > 0))
            send("#{field}=", send(field) | (1 << i))
          else
            send("#{field}=", send(field) & ~(1 << i))
          end
        end

        define_method("#{options[:method_prefix]}#{flag}?") do
          send(field) & (1 << i) > 0
        end

        define_method("#{options[:method_prefix]}#{flag}") do
          send(field) & (1 << i) > 0
        end

        define_method("was_#{options[:method_prefix]}#{flag}?") do
          send("#{field}_was") & (1 << i) > 0
        end

        define_method("#{options[:method_prefix]}#{flag}_changed?") do
          send("#{field}_was") & (1 << i) != send("#{field}") & (1 << i)
        end
        
        define_method("#{options[:method_prefix]}#{flag}=") do |value|
          if (value && (!value.respond_to?(:to_i) || value.to_i > 0))
            send("#{field}=", send(field) | (1 << i))
          else
            send("#{field}=", send(field) & ~(1 << i))
          end
        end
        
        if options[:inverse_method_prefix]
          define_method("#{options[:inverse_method_prefix]}#{flag}?") do
            send(field) & (1 << i) == 0
          end

          define_method("#{options[:inverse_method_prefix]}#{flag}") do
            send(field) & (1 << i) == 0
          end

          define_method("was_#{options[:inverse_method_prefix]}#{flag}?") do
            send("#{field}_was") & (1 << i) == 0
          end

          define_method("#{options[:inverse_method_prefix]}#{flag}_changed?") do
            send("#{field}_was") & (1 << i) != send("#{field}") & (1 << i)
          end
          
          define_method("#{options[:inverse_method_prefix]}#{flag}=") do |value|
            if (!value || value.respond_to?(:to_i) && value.to_i <= 0)
              send("#{field}=", send(field) | (1 << i))
            else
              send("#{field}=", send(field) & ~(1 << i))
            end
          end
        end
      end
    end
  
    def nested_attributes(attributes, options={})
      field = (options[:in] || :params).to_sym
      
      serialize field, Hash
      
      define_method field do
        self[field] ||= {}
      end

      define_method "#{field}=" do |value|
        self[field] = value
      end
    
      attributes.each do |key, type|
        define_method(key) do 
          hash = send(field)
          hash[key]
        end
        
        define_method("#{key}=") do |value|
          hash = send(field)
          case type
          when :int 
            value = value.to_i
          when :string
            value = value.to_s
          when :array
            value = value.to_a
          else
            value
          end
          hash[key] = value
          send("#{field}=", hash)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecordExtensions)