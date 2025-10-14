class OutgoingReceipt < ApplicationRecord
  belongs_to :user
  belongs_to :fiscal_quarter, optional: true
  has_one_attached :receipt_file

  enum status: {
    paid: 'paid',
    pending: 'pending',
    rejected: 'rejected'
  }

  before_validation :set_defaults

  def self.ransackable_attributes(auth_object = nil)
    ["id", "user_id", "status", "uploaded_on", "notes", "fiscal_quarter_id", "service", "amount"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

  def set_defaults
    self.uploaded_on = DateTime.now if self.uploaded_on.blank?
  end
end
