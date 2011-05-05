module HelperExtensions
  
  module DateTimeSelectorExtensions
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:alias_method_chain, :select_hour, :twelve_hour_time)
    end
    
    module InstanceMethods
      def select_hour_with_twelve_hour_time 
        return select_hour_without_twelve_hour_time(@datetime, @options) unless @options[:twelve_hour].eql? true
        if @options[:use_hidden] || @options[:discard_hour]
          build_hidden(:hour, hour)
        else
          select_options = []
          0.step(23, 1) do |value|
            if value == 0 && @options[:midnight]
              text = @options[:midnight].eql?(true) ? 'midnight' : @options[:midnight]
            elsif value == 12 && @options[:noon]
              text = @options[:noon].eql?(true) ? 'noon' : @options[:noon]
            else
              text = "#{value == 12 ? 12 : (value / 12 == 1 ? value % 12 : value)}#{value <= 11 ? ' AM' : ' PM'}"
            end
            tag_options = { :value => value }
            tag_options[:selected] = "selected" if hour == value
            select_options << content_tag(:option, text, tag_options)
          end
          select_options.rotate!(@options[:offset].to_i)
          select_options.unshift(@options[:prompt]) if @options[:prompt].present?
          build_select(:hour, (select_options.join("\n") + "\n").html_safe)
        end       
      end  
    end
  end
end

ActionView::Helpers::DateTimeSelector.send(:include, HelperExtensions::DateTimeSelectorExtensions)