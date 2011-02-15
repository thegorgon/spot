require "geo"

module Geo
  class Cleaner        
    class << self
      def clean(params)
        if (name = params[:name])
          result = clean_name(name.clone)
          result.length > 0 ? result : name
        elsif address = params[:address] 
          clean_address(address.clone)
        else
          nil
        end
      end
    
      private
    
      def clean_name(name)
        prepare(name)
        remove_punctuation(name)
        # remove_extraneous_words(name)
        cleanup(name)
        name
      end
    
      def clean_address(address)
        prepare(address)
        remove_punctuation(address)
        expand_abbreviations(address)
        cleanup(address)
        address
      end    
    
      def expand_abbreviations(string)
        Geo.all_abbreviations.each do |short, long|
          string.gsub!(/\b#{short}\.?\b/i, " #{long} ")
        end
        string.gsub!(/\#\s*([\w\d])/, '#\1')
      end
      
      def prepare(string)
        string.strip!
        string.downcase!
      end
      
      def cleanup(string)
        string.strip!
        string.gsub!(/\s+/, " ")
      end
    
      def remove_punctuation(string)
        string.gsub!(/\b&\b/, ' and ')
        string.gsub!(/-/, ' ')
        string.gsub!(/[^(\w\d\s\#)]/, '')
      end
      
      def remove_extraneous_words(string)
        string.gsub!(/\b(#{Geo::EXTRANEOUS_WORDS.join("|")})\b/, " ")
      end
    end
  end
end