class OutgoingReceipt < ApplicationRecord
  belongs_to :user
  belongs_to :fiscal_quarter, optional: true
  has_one_attached :receipt_file

  enum status: {
    paid: 'paid',
    pending: 'pending',
    rejected: 'rejected'
  }

  def self.ransackable_attributes(auth_object = nil)
    ["id", "user_id", "status", "uploaded_on", "notes", "fiscal_quarter_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end
end
