
class Service < ApplicationRecord
  belongs_to :user
  has_many :outgoing_receipts, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    ["id", "user_id", "name", "description", "amount", "currency", "active", "variable_amount"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end
end
