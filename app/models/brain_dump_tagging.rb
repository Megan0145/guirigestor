class BrainDumpTagging < ApplicationRecord
  belongs_to :brain_dump
  belongs_to :brain_dump_tag
  
  validates :brain_dump_id, uniqueness: { scope: :brain_dump_tag_id }
end

