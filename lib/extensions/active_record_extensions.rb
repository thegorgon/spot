module ActiveRecordExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
  end
  
  module InstanceMethods
  end
  
  module ClassMethods
    def setting_flags(flags, options={})
      attribute = options[:attr] || "settings"
      field = options[:field] || "setting_flags"
      scope :with_setting, lambda { |s| where("#{field} & #{1 << flags.index(s)} > 0") }
      scope :without_setting, lambda { |s| where("#{field} & #{1 << flags.index(s)} = 0") }
      
      
      define_method "#{attribute}=" do |value|
        (flags & value.to_a).each do |setting|
          send("#{options[:method_prefix]}#{setting}=", true) if respond_to?("#{options[:method_prefix]}#{setting}=")
        end
        (flags - value.to_a).each do |setting|
          send("#{options[:method_prefix]}#{setting}=", false) if respond_to?("#{options[:method_prefix]}#{setting}=")
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
  end
end

ActiveRecord::Base.send(:include, ActiveRecordExtensions)