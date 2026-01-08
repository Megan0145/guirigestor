class Bty < ApplicationRecord
  self.table_name = 'btys'
  
  validates :value, inclusion: { in: [true, false] }
  validates :date, presence: true, uniqueness: true
  
  scope :for_year, ->(year) { where(date: Date.new(year, 1, 1)..Date.new(year, 12, 31)) }
  scope :for_month, ->(year, month) { where(date: Date.new(year, month, 1)..Date.new(year, month, -1)) }
  scope :ordered, -> { order(date: :asc) }
  
  def yes?
    value == true
  end
  
  def no?
    value == false
  end
end

