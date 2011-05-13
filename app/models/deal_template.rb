class DealTemplate < ActiveRecord::Base
  DISCOUNTS = [20, 25, 40, 50]
  MAX_COLOR = 256**3 - 1
  MAX_PER_BUSINESS = 100
  COLORS = ["610f00", "ca5939", "6eba5a", "0b26b9", "fec45c", "5e1322", "b1d612", "0b2fae", "d0c7c2", "2bc5c6", "267bf5", "61a9b7", "af8ce2", "dca78d", "ceab76", "c50d2d", "aa545b", "2bdcad", "6e0321", "ead721", "b7f5bf", "7ec729", "8f047b", "33f0f9", "41ccb4", "1bd4a9", "d6a4fb", "7c6370", "8f9c0e", "348382", "ff2b37", "51362b", "96547c", "f4ee45", "33c07a", "2267d1", "6746b1", "0ddf1d", "227b04", "4111aa", "712320", "838c34", "b19501", "5536ad", "da44b1", "6294e7", "a7adbd", "57c4e5", "e89148", "a49290", "d80cae", "a038a1", "2d87f2", "e4c559", "7dc971", "3ef250", "0a36aa", "38de32", "3beba2", "03c24d", "8791e8", "af4f01", "1ad38c", "e50407", "52bb3c", "6f8922", "58c97f", "1bc630", "3890eb", "e33381", "eccf24", "be118f", "1e2266", "f434b1", "e2eda0", "55197e", "f2aabd", "f2c812", "386a4a", "7aff3c", "88a8eb", "0f51b5", "fdbe59", "1b8030", "495482", "89ba64", "260cbc", "af18d3", "bf3af2", "521333", "74e27d", "e40a04", "706886", "a49c60", "815511", "9acf62", "b8866d", "7f6786", "5e8188", "941ad1", "87173c"]
  has_many :deal_events
  belongs_to :business
  attr_protected :approved_at
  
  validates :name, :presence => true
  validates :deal_count, :presence => true, :numericality => {:greater_than => 0, :less_than => 101}
  validates :discount_percentage, :inclusion => DISCOUNTS
  validates :business, :presence => true
  acts_as_list :scope => 'business_id = #{business_id} AND removed_at IS NULL'

  scope :active, where(:removed_at => nil)

  def self.discounts
    unless @discounts
      @discounts = {}
      DISCOUNTS.each do |d|
        @discounts["#{d}%"] = d
      end
    end
    @discounts
  end
  
  def approved?
    !!approved_at
  end
  
  def approve!
    update_attribute(:approved_at, Time.now)
  end
  
  def summary
    "#{deal_count} deals per day at #{discount_percentage}% off, #{timeframe}"
  end

  def color
    Color.hex_series(position.to_i).first
  end
  
  def timeframe
    if all_day?
      "all day"
    else
      "#{Time.twelve_hour(start_time, :midnight => true, :noon => true)} to #{Time.twelve_hour(end_time, :midnight => true, :noon => true)}"
    end
  end
  
  def all_day?
    start_time == 0 && end_time == 0
  end

  def remove!
    update_attribute(:removed_at, Time.now)
  end
  
  def removed?
    !!removed_at
  end

  def as_json(*args)
    hash = super
    hash['summary'] = summary
    hash['color'] = color
    hash['timeframe'] = timeframe
    hash
  end
end