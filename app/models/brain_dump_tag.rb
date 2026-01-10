class BrainDumpTag < ApplicationRecord
  has_many :brain_dump_taggings, dependent: :destroy
  has_many :brain_dumps, through: :brain_dump_taggings
  
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  
  before_save :downcase_name
  
  scope :ordered, -> { order(:name) }
  scope :with_dumps, -> { joins(:brain_dumps).distinct }
  
  def dump_count
    brain_dumps.count
  end
  
  private
  
  def downcase_name
    self.name = name.downcase.strip if name.present?
  end
end

