class FiscalQuarter < ApplicationRecord
  belongs_to :user
  has_many :autonomo_payments, dependent: :destroy
  has_many :outgoing_receipts, dependent: :destroy
  has_many :invoices, dependent: :destroy
  
  before_validation :generate_defaults

  validates :identifier, presence: true, uniqueness: true
  validates :passcode, presence: true, uniqueness: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  enum status: {
    active: 'active',
    inactive: 'inactive'
  }

  def self.ransackable_attributes(auth_object = nil)
    ["id", "user_id", "name", "start_date", "end_date", "status", "notes", "identifier", "passcode", "year", "quarter"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

  def calculate_quarter
    case self.start_date.month
    when 1, 2, 3
      "Q1"
    when 4, 5, 6
      "Q2"
    when 7, 8, 9
      "Q3"
    when 10, 11, 12
      "Q4"
    end
  end

  def generate_defaults
    self.year = self.start_date.year if self.year.blank?
    self.quarter = self.calculate_quarter if self.quarter.blank?
    self.name = "#{self.year} - #{self.quarter}" if self.name.blank?
    self.identifier = SecureRandom.alphanumeric(5).downcase if self.identifier.blank?
    self.passcode = SecureRandom.alphanumeric(5).downcase if self.passcode.blank?
  end
end
