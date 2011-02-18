module Jobs
  class PlaceImageProcessor
    @queue = :images
    
    def self.perform(instance_klass, instance_id, attachment_name, uri=nil)
      instance = instance_klass.constantize.find(instance_id)
      attachment_name = attachment_name.to_sym
      if uri
        perform_file_download(instance, uri, attachment_name)
      else
        perform_image_processing(instance, attachment_name)
      end
    end
    
    private
    
    def self.perform_file_download(instance, uri, attachment_name=:image)
      file = download_external_file(uri)
      instance.attachment_for(attachment_name).assign(file)
      perform_image_processing(instance, attachment_name, file)
    end
    
    def self.perform_image_processing(instance, attachment_name=:image, file=nil)
      instance.attachment_for(attachment_name).reprocess!
      file ||= download_external_file(instance.attachment_for(attachment_name).url)
      lq_thumb = Paperclip.processor(:thumbnail).make(file, {:geometry => "117x84#", :convert_options => '-quality 10 -strip -colorspace RGB -resample 72', :format => 'jp2'}, instance)
      instance.image_thumbnail = ActiveSupport::Base64.encode64(lq_thumb.to_a.join)      
      instance.save!
    end
    
    def self.download_external_file(uri)
      file = nil
      begin
        io = open(uri) rescue nil
        def io.original_filename; base_uri.path.split('/').last; end
        file = io if io.original_filename.present?
      rescue
        file = nil
      end
      file
    end
  end
end