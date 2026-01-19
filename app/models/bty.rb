class Bty < ApplicationRecord
  self.table_name = 'btys'
  
  # Value constants: 1 = Yes (better), 0 = Same, -1 = No (worse)
  YES = 1
  SAME = 0
  NO = -1
  
  validates :value, inclusion: { in: [YES, SAME, NO] }
  validates :date, presence: true, uniqueness: true
  
  scope :for_year, ->(year) { where(date: Date.new(year, 1, 1)..Date.new(year, 12, 31)) }
  scope :for_month, ->(year, month) { where(date: Date.new(year, month, 1)..Date.new(year, month, -1)) }
  scope :ordered, -> { order(date: :asc) }
  
  def yes?
    value == YES
  end
  
  def same?
    value == SAME
  end
  
  def no?
    value == NO
  end
  
  # Returns the score contribution for calculations
  # Yes = +1, Same = 0, No = -1
  def score
    value
  end
end
