module ActiveRecordExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
    base.send(:before_create, :set_newly_created)
    base.send(:after_commit, :clear_newly_created)
  end
  
  module InstanceMethods
    def set_newly_created
      @newly_created = true
    end
    
    def clear_newly_created
      @newly_created = false
    end
    
    def newly_created?
      !!@newly_created
    end
  end
  
  module ClassMethods
    def setting_flags(flags, options={})
      attribute = options[:attr] || "settings"
      field = options[:field] || "setting_flags"
      protected_flags = options[:protected] || []
      scope :with_setting, lambda { |s| where("#{field} & #{1 << flags.index(s)} > 0") }
      scope :without_setting, lambda { |s| where("#{field} & #{1 << flags.index(s)} = 0") }
      
      
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