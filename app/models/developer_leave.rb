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
  
  def duration_days
    (end_date - start_date).to_i + 1
  end
  
  def spans_date?(date)
    date >= start_date && date <= end_date
  end
  
  private
  
  def end_date_after_start_date
    return unless start_date && end_date
    if end_date < start_date
      errors.add(:end_date, "must be on or after start date")
    end
  end
end

