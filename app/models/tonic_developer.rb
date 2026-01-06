class TonicDeveloper < ApplicationRecord
  has_many :developer_leaves, class_name: 'DeveloperLeave', dependent: :destroy
  
  validates :name, presence: true
  
  def display_name
    "#{name}#{project.present? ? " (#{project})" : ''}"
  end
end

