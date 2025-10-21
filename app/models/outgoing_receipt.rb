class OutgoingReceipt < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
  
  attr_accessor :part_of_bulk_upload
  
  belongs_to :user
  belongs_to :fiscal_quarter, optional: true
  belongs_to :service, optional: true
  has_one_attached :receipt_file
  
  # Conditional validations - skip when part of bulk upload
  validates :service, presence: true, unless: :part_of_bulk_upload
  validates :status, presence: true, unless: :part_of_bulk_upload
  validates :fiscal_quarter, presence: true, unless: :part_of_bulk_upload

  scope :assigned, -> { where(assigned: true) }
  scope :unassigned, -> { where(assigned: false) }
  
  enum status: {
    paid: 'paid',
    unsubmitted: 'unsubmitted',
    pending: 'pending',
    rejected: 'rejected'
  }

  before_validation :set_defaults

  def self.ransackable_attributes(auth_object = nil)
    ["id", "user_id", "status", "uploaded_on", "notes", "fiscal_quarter_id", "service", "service_id", "amount", "currency", "month", "year", "part_of_bulk_upload", "assigned"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end

  def display_month
    if self.month.present?
      return I18n.t("months.#{months[self.month]&.downcase}") 
    end
    return nil
  end

  def display_year
    return self.year if self.year.present?
    return nil
  end

  def display_month_and_year
    return "#{self.display_month} #{self.display_year}" if self.month.present? && self.year.present?
    return "-"
  end

  def display_amount
    return number_to_currency(self.amount, unit: available_currencies[self.currency]) if self.amount.present? && self.currency.present? && self.amount.to_f > 0
    return number_to_currency(self.service.amount, unit: available_currencies[self.service.currency]) if self.service.present? && self.service.amount.present? && self.service.currency.present? && self.service.amount.to_f > 0
    return nil
  end

  def display_notes
    return self.notes if self.notes.present?
    return self.service.description if self.service.present? && self.service.description.present?
    return nil
  end

  def set_defaults
    self.uploaded_on = DateTime.now if self.uploaded_on.blank?
    self.currency = 'EUR' if self.currency.blank?
    self.notes = self.service.description if self.notes.blank? && self.service.present? && self.service.description.present?
  end
end
