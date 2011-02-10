module Flickr
  class Object
    def self.instance_keys
      self::INSTANCE_KEYS
    end
    
    def self.parse(record)
      if (record && record.kind_of?(Hash))
        object = new
        instance_keys.each do |key|
          object.send("#{key}=", record[key.to_s])
        end
        object
      else
        nil
      end
    end
  end
end