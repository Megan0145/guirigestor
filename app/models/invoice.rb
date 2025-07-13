class Invoice < ApplicationRecord
  belongs_to :user
  has_many :invoice_line_items, dependent: :destroy
  has_one_attached :company_logo
  accepts_nested_attributes_for :invoice_line_items, allow_destroy: true

  # Calculates subtotal (sum of all line items)
  def subtotal_amount
    invoice_line_items.sum(&:total)
  end

  # Tax value based on tax_rate column (e.g. 21 for 21%)
  def tax_amount
    return 0 unless tax_rate.present?
    (subtotal_amount * (tax_rate / 100.0)).round(2)
  end

  # Subtotal + tax
  def total_amount
    (subtotal_amount + tax_amount).round(2)
  end
end
