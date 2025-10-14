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

  after_create :populate_default_outgoing_receipts

  enum status: {
    active: 'active',
    ready_for_submission: 'ready_for_submission',
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

  def months_in_fiscal_quarter
    (self.start_date.month..self.end_date.month).to_a
  end

  def populate_default_outgoing_receipts
    # first get all months belonging to the fiscal quarter
    months = self.months_in_fiscal_quarter
    year = self.start_date.year

    # then get all the active services for the user
    services = self.user.services.where(active: true)

    services.each do |service|
      months.each do |month|
        outgoing_receipt = OutgoingReceipt.find_or_initialize_by(
          user: self.user,
          fiscal_quarter: self,
          service: service,
          month: month,
          year: year,
          status: 'unsubmitted',
        )
        
        outgoing_receipt.currency = service.currency
        outgoing_receipt.amount =  service.variable_amount ? 0.0 : service.amount
        outgoing_receipt.notes = service.description
        outgoing_receipt.month = month
        outgoing_receipt.year = year
        outgoing_receipt.status = 'unsubmitted'
        
        outgoing_receipt.save!
      end
    end
  end
end
