class Bty < ApplicationRecord
  self.table_name = 'btys'
  
  validates :value, inclusion: { in: [true, false] }
  validates :date, presence: true, uniqueness: true
  
  scope :for_year, ->(year) { where("strftime('%Y', date) = ?", year.to_s) }
  scope :for_month, ->(year, month) { where("strftime('%Y', date) = ? AND strftime('%m', date) = ?", year.to_s, month.to_s.rjust(2, '0')) }
  scope :ordered, -> { order(date: :asc) }
  
  def yes?
    value == true
  end
  
  def no?
    value == false
  end
end

