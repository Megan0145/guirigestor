class FiscalQuarter < ApplicationRecord
  belongs_to :user
  has_many :autonomo_payments, dependent: :destroy
  has_many :outgoing_receipts, dependent: :destroy
  has_many :invoices, dependent: :destroy

  enum status: {
    active: 'active',
    inactive: 'inactive'
  }

  def self.ransackable_attributes(auth_object = nil)
    ["id", "user_id", "name", "start_date", "end_date", "status", "notes", "identifier", "passcode"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end
end
