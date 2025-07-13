class InvoiceLineItem < ApplicationRecord
  belongs_to :invoice

  def total
    (rate * quantity).round(2)
  end
end
