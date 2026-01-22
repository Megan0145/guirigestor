class DeveloperLeave < ApplicationRecord
  belongs_to :tonic_developer
  
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date
  
  scope :for_month, ->(date) {
    start_of_month = date.beginning_of_month
    end_of_month = date.end_of_month
    where("start_date <= ? AND end_date >= ?", end_of_month, start_of_month)
  }
  
  scope :for_date, ->(date) {
    where("start_date <= ? AND end_date >= ?", date, date)
  }
  
  # Calculate total duration accounting for half days
  # Returns a float (e.g., 2.5 for 2 and a half days)
  def duration_days
    base_days = (end_date - start_date).to_i + 1
    
    # Subtract 0.5 for each half day
    base_days -= 0.5 if start_half_day?
    base_days -= 0.5 if end_half_day?
    
    base_days
  end
  
  # Formatted duration string for display
  def duration_display
    days = duration_days
    if days == days.to_i
      "#{days.to_i} day#{'s' if days.to_i != 1}"
    else
      "#{days} days"
    end
  end
  
  def spans_date?(date)
    date >= start_date && date <= end_date
  end
  
  # Check if a specific date within the leave is a half day
  def half_day_on?(date)
    return false unless spans_date?(date)
    (date == start_date && start_half_day?) || (date == end_date && end_half_day?)
  end
  
  # Convenience methods
  def start_half_day?
    start_half_day == true
  end
  
  def end_half_day?
    end_half_day == true
  end
  
  private
  
  def end_date_after_start_date
    return unless start_date && end_date
    if end_date < start_date
      errors.add(:end_date, "must be on or after start date")
    end
  end
end

