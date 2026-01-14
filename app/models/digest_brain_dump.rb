class DigestBrainDump < ApplicationRecord
  belongs_to :digest, class_name: "BrainDigest"
  belongs_to :brain_dump
end

