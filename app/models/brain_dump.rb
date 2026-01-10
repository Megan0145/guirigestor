class BrainDump < ApplicationRecord
  # Encrypt both content fields at rest - decrypted automatically when accessed
  encrypts :content      # The enriched/cleaned version (shown by default)
  encrypts :raw_content  # The original raw input (preserved for safety)
  
  has_many :brain_dump_taggings, dependent: :destroy
  has_many :tags, through: :brain_dump_taggings, source: :brain_dump_tag
  
  validates :content, presence: true
  validates :date, presence: true
  
  scope :ordered, -> { order(date: :desc, created_at: :desc) }
  scope :for_tag, ->(tag_id) { joins(:tags).where(brain_dump_tags: { id: tag_id }) }
  # Note: Can't search encrypted content with SQL - search is done in Ruby in the controller
  
  # Check if this dump has been enriched by AI
  def enriched?
    raw_content.present? && content != raw_content
  end
  
  # For display - use enriched if available, otherwise raw
  def display_content(show_raw: false)
    if show_raw && raw_content.present?
      raw_content
    else
      content
    end
  end
  
  # Search across both raw and enriched content
  def matches_search?(query)
    return true if query.blank?
    query_downcase = query.downcase
    content.to_s.downcase.include?(query_downcase) || 
      raw_content.to_s.downcase.include?(query_downcase)
  end
  
  def tag_list
    tags.pluck(:name).join(", ")
  end
  
  def tag_list=(names)
    self.tags = names.split(",").map(&:strip).reject(&:blank?).uniq.map do |name|
      BrainDumpTag.find_or_create_by(name: name.downcase)
    end
  end
end

