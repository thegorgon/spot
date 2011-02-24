require "geo"

module Geo
  class Cleaner        
    class << self
      def clean(params)
        options = params.slice(:extraneous)
        if (name = params[:name])
          result = clean_name(name.clone, options)
          result.length > 0 ? result : name
        elsif address = params[:address] 
          clean_address(address.clone, options)
        else
          nil
        end
      end
      
      def remove_extraneous_words(string)
        string.gsub!(/\b(#{Geo::EXTRANEOUS_WORDS.join("|")})\b/, " ")
        string
      end
    
      private
    
      def clean_name(name, options={})
        name = prepare(name)
        name = remove_punctuation(name)
        name = remove_extraneous_words(name) if options[:extraneous]
        name = cleanup(name)
        name
      end
    
      def clean_address(address, options={})
        address = prepare(address)
        address = remove_punctuation(address)
        address = expand_abbreviations(address)
        address = cleanup(address)
        address
      end    
    
      def expand_abbreviations(string)
        Geo.all_abbreviations.each do |short, long|
          string.gsub!(/\b#{short}\.?\b/i, " #{long} ")
        end
        string.gsub!(/\#\s*([\w\d])/, '#\1')
        string
      end
      
      def prepare(string)
        string.strip!
        string.downcase!
        string
      end
      
      def cleanup(string)
        string.strip!
        string.gsub!(/\s+/, " ")
        string
      end
    
      def remove_punctuation(string)
        string.gsub!(/\b&\b/, ' and ')
        string.gsub!(/\-/, ' ')
        string = string.mb_chars.normalize(:kd).gsub(/[^\p{L}\s\p{N}]/ui, '').to_s
        string
      end
    end
  end
end