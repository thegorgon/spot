class Sweepstake < ActiveRecord::Base
  belongs_to :place
  has_many :entries, :class_name => "SweepstakeEntry"
  
  validates :short_summary, :presence => true
  validates :description, :presence => true
  validates :grand_prize, :presence => true
  validates :prize_value, :presence => true, :numericality => {:minimum => 0}
  validates :name, :presence => true
  validates :place, :presence => true
  validates :starts_on, :presence => true
  validates :ends_on, :presence => true
  validate :valid_start_and_end_dates
  
  scope :pending, lambda { where(["starts_on > ?", Time.now]) }
  scope :active, lambda { where(["starts_on < ? AND ends_on > ?", Time.now, Time.now]) }
  scope :closed, lambda { where(["ends_on < ?", Time.now]) }
  scope :without_winner, where("winning_entry_id IS NULL")
  scope :with_winner, where("winning_entry_id IS NOT NULL")
  scope :ready_for_winner, closed.without_winner
  scope :complete, closed.with_winner
  
  def self.filter(params)
    finder = self
    n = params[:filter].to_i
    finder = finder.pending           if n & (1 << 0) > 0
    finder = finder.active            if n & (1 << 1) > 0
    finder = finder.closed            if n & (1 << 2) > 0
    finder = finder.complete          if n & (1 << 3) > 0
    finder = finder.ready_for_winner  if n & (1 << 4) > 0
    finder = finder.includes(:place)
    finder.page(params[:page]).per(params[:per_page])
  end
  
  def self.time_zone
    ActiveSupport::TimeZone.zones_map['Pacific Time (US & Canada)']
  end
  
  def self.now
    Time.now.in_time_zone(self.class.time_zone)
  end
  
  def place_name
    place.try(:name)
  end
  
  def place_name=(value)
  end
  
  def starts_at
    Sweepstake.time_zone.parse(starts_on.strftime("%Y-%m-%d 00:00:00"))
  end
  
  def ends_at
    Sweepstake.time_zone.parse(ends_on.strftime("%Y-%m-%d 01:00:00"))
  end
  
  def pending?
    starts_at > Time.now
  end
  
  def active?
    starts_at < Time.now && ends_at > Time.now
  end
  
  def closed?
    ends_at < Time.now && winning_entry_id.nil?
  end
  
  def complete?
    ends_at < Time.now && winning_entry
  end
  
  def winners_announced_at
    ends_at + 1.day
  end
  
  def status
    if pending?
      "Pending"
    elsif active?
      "Active"
    elsif closed?
      "Closed"
    elsif complete?
      "Complete"
    else
      "N/A"
    end
  end
  
  def to_param
    "#{id}-#{name.parameterize}"
  end
  
  def winning_entry
    if @winning_entry.nil?
      @winning_entry = SweepstakeEntry.find_by_id(winning_entry_id) if winning_entry_id
      @winning_entry ||= select_winning_entry!
    end
    @winning_entry
  end
  
  def select_winning_entry!
    submission_count = entries.sum(:submissions)
    pick = rand(submission_count)

    runner = 0
    winner = nil
    entries.find_each do |entry|
      runner += entry.submissions
      if runner > pick
        winner = entry
        update_attribute(:winning_entry_id, entry.id)
        break
      end
    end
    winner
  end
  
  private
  
  def valid_start_and_end_dates
    errors.add(:starts_on, "must be in the future") if starts_at < Time.now 
    errors.add(:ends_on, "must be after start date") if ends_at < starts_at
  end
end