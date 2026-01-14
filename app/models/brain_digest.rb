class BrainDigest < ApplicationRecord
  self.table_name = "digests"
  encrypts :content

  has_many :digest_brain_dumps, dependent: :destroy, foreign_key: :digest_id
  has_many :brain_dumps, through: :digest_brain_dumps
  has_many :digest_messages, dependent: :destroy, foreign_key: :digest_id

  validates :digest_type, presence: true, inclusion: { in: %w[scheduled custom] }
  validates :schedule_period, inclusion: { in: %w[weekly monthly yearly] }, allow_nil: true

  scope :scheduled, -> { where(digest_type: 'scheduled') }
  scope :custom, -> { where(digest_type: 'custom') }
  scope :ordered, -> { order(created_at: :desc) }

  def scheduled?
    digest_type == 'scheduled'
  end

  def custom?
    digest_type == 'custom'
  end

  def display_title
    title.presence || "#{schedule_period&.capitalize} Digest" || "Custom Digest"
  end
end
