class DigestMessage < ApplicationRecord
  encrypts :content

  belongs_to :digest, class_name: "BrainDigest"

  validates :role, presence: true, inclusion: { in: %w[user assistant] }
  validates :content, presence: true

  scope :ordered, -> { order(created_at: :asc) }

  def user?
    role == 'user'
  end

  def assistant?
    role == 'assistant'
  end
end

