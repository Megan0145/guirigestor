class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :fiscal_quarter, optional: true
  has_many :invoice_line_items, dependent: :destroy
  has_one_attached :company_logo
  accepts_nested_attributes_for :invoice_line_items, allow_destroy: true

  # options for currency
  CURRENCIES = {
    'EUR' => '€',
    'USD' => '$',
  }.freeze
  
  # Calculates subtotal (sum of all line items)
  def subtotal_amount
    invoice_line_items.sum(&:total)
  end

  def logo_url
    if company_logo.attached?
      Rails.env.development? ? "data:image/png;base64,#{Base64.strict_encode64(company_logo.download)}" : url_for(company_logo)
    else
      nil
    end
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
  def self.ransackable_attributes(auth_object = nil)
    [
      "id",
      "user_id",
      "invoice_number",
      "currency",
      "frequency",
      "rate",
      "recipient_company_name",
      "recipient_vat_number",
      "recipient_address",
      "recipient_email",
      "sender_company_name",
      "sender_tax_number",
      "sender_address",
      "notes",
      "terms",
      "bank_details",
      "tax_rate",
      "issued_on",
      "due_on",
      "fiscal_quarter_id"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    ["invoice_line_items", "user"]
  end
end
