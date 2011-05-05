module Jobs
  class PlaceImageProcessor
    extend IOStream
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
      perform_image_processing(instance, attachment_name)
    end
    
    def self.perform_image_processing(instance, attachment_name=:image)
      instance.attachment_for(attachment_name).reprocess!
      file = download_external_file(instance.attachment_for(attachment_name).url_without_processed(:original))
      lq_thumb = Paperclip.processor(:thumbnail).make(file, {:geometry => "117x84#", :convert_options => '-quality 10 -strip -colorspace RGB', :format => 'jp2'}, instance)
      instance.image_thumbnail = ActiveSupport::Base64.encode64(lq_thumb.to_a.join)
      instance.image_processing = false
      instance.save!
    end
    
    def self.download_external_file(uri)
      file = nil
      begin
        io = open(uri) rescue nil
        file = to_tempfile(io) if io
      rescue => e
        puts "Rescued error : #{e.message}"
        file = nil
      end
      file
    end
  end
end