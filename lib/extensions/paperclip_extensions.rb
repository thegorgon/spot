module Delayed
  module Paperclip
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods      
      def process_attachment_in_background?(name)
        !!(@attachments_in_background ||= {})[name]
      end
      
      def process_attachment_in_background(name, options={})
        job = options[:job] rescue nil
        raise ArgumentError, "Invalid image processing job class : #{options[:job].inspect}" unless job.is_a?(Class) && job.respond_to?(:perform)
        (@attachments_in_background ||= {})[name] = true
        
        include InstanceMethods
        
        define_method "#{name}_changed?" do
          attachment_has_changed?(name)
        end

        set_callback :"#{name}_post_process", :before do
          return unless self.send("#{name}_changed?")
          false # halts processing
        end

        define_method "enqueue_job_for_#{name}" do
          return unless self.send("#{name}_changed?")

          Resque.enqueue(job, self.class.name, read_attribute(self.class.primary_key), name.to_sym)
        end

        define_method "#{name}_processed!" do
          return unless column_exists?(:"#{name}_processing")
          return unless self.send(:"#{name}_processing?")

          self.send("#{name}_processing=", false)
          self.save(:validate => false)
        end

        define_method "#{name}_processing!" do
          return unless column_exists?(:"#{name}_processing")
          return if self.send(:"#{name}_processing?")
          return unless self.send(:"#{name}_changed?")

          self.send("#{name}_processing=", true)
        end
        
        before_save :"#{name}_processing!"
        after_save  :"enqueue_job_for_#{name}"
      end
    end

    module InstanceMethods    
      def attachment_has_changed?(name)
        ['file_size', 'file_name', 'content_type', 'updated_at'].each do |attribute|
          full_attribute = "#{name}#{attribute}_changed?".to_sym

          next unless self.respond_to?(full_attribute)
          return true if self.send("#{name}#{attribute}_changed?")
        end

        false
      end
           
      def column_exists?(column)
        self.class.columns_hash.has_key?(column.to_s)
      end
    end      
  end
end
ActiveRecord::Base.send(:include, Delayed::Paperclip)

module Paperclip
  class Attachment
    
    def updated_at
      time = instance_read(:updated_at) || @instance.updated_at
      time && time.to_f.to_i
    end

    def initialize_with_processing(name, instance, options={})
      initialize_without_processing(name, instance, options)
      @processing_url = options[:processing_url] || @default_url
    end
    alias_method_chain :initialize, :processing
    
    def url_with_processed(style = default_style, include_updated_timestamp = true)
      return url_without_processed(style, include_updated_timestamp) unless @instance.class.process_attachment_in_background?(@name)
      if @instance.column_exists?(:"#{@name}_processing")
        if @instance.send(:"#{@name}_processing?")
          if @instance.send(:"#{@name}_changed?")
            url_without_processed style, include_updated_timestamp
          else
            interpolate(@processing_url, style)
          end
        else
          url_without_processed style, include_updated_timestamp
        end
      else
        url_without_processed style, include_updated_timestamp
      end
    end    
    alias_method_chain :url, :processed

    def processed_url(style_name = default_style, use_timestamp = @use_timestamp)
      if file? || (@instance.column_exists?(:"#{@name}_processing") && @instance.send(:"#{@name}_processing?"))
        original = @instance.image_file_name
        @instance.image_file_name = original || "file.jpg"
        url = interpolate(@url, style_name)
        @instance.image_file_name = original
      else
        url = interpolate(@default_url, style_name)
      end
      use_timestamp && updated_at ? [url, updated_at].compact.join(url.include?("?") ? "&" : "?") : url
    end
  end
end