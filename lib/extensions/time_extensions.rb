module TimeExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
  end
  
  module InstanceMethods
    def calendar_start
      month_start = self.utc.at_midnight.at_beginning_of_month
      month_start - month_start.wday.days
    end
  end
  
  module ClassMethods
    def twelve_hour(value, options={})
      if value == 0 && options[:midnight]
        text = options[:midnight].eql?(true) ? 'midnight' : options[:midnight]
      elsif value == 12 && options[:noon]
        text = options[:noon].eql?(true) ? 'noon' : options[:noon]
      else
        text = "#{value == 12 ? 12 : (value / 12 == 1 ? value % 12 : value)}#{value <= 11 ? 'am' : 'pm'}"
      end
    end
  end
end


Time.send(:include, TimeExtensions)

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
  :w3c => '%Y-%m-%dT%H:%M:%S+00:00'
)