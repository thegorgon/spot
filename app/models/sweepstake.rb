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
  scope :ended, lambda { where(["ends_on < ?", Time.now]) }
  scope :without_winner, where("winning_entry_id IS NULL")
  scope :with_winner, where("winning_entry_id IS NOT NULL")
  scope :ready_for_winner, ended.without_winner
  scope :complete, ended.with_winner
  
  def self.filter(params)
    finder = self
    n = params[:filter].to_i
    finder = finder.pending           if n & (1 << 0) > 0
    finder = finder.active            if n & (1 << 1) > 0
    finder = finder.ended             if n & (1 << 2) > 0
    finder = finder.complete          if n & (1 << 3) > 0
    finder = finder.ready_for_winner  if n & (1 << 4) > 0
    finder = finder.includes(:place)
    finder.page(params[:page]).per(params[:per_page])
  end
  
  def place_name
    place.try(:name)
  end

  def place_name=(value)
  end
  
  def pending?
    starts_on.to_time.utc > Time.now.utc
  end
  
  def active?
    starts_on.to_time.utc < Time.now.utc && ends_on.to_time.utc > Time.now.utc
   end
  
  def ended?
    (ends_on.to_time + 1.hour).utc < Time.now.utc && winning_entry_id.nil?
  end
  
  def complete?
    ends_on.to_time.utc < Time.now.utc && winning_entry
  end
  
  def winners_announced_at
    ends_on + 1.day
  end
  
  def status
    if pending?
      "Pending"
    elsif active?
      "Active"
    elsif ended?
      "Ended"
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
    errors.add(:starts_on, "must be in the future") if starts_on <= Time.now 
    errors.add(:ends_on, "must be after start date") if ends_on <= starts_on
  end
end