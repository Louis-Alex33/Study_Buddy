class Message < ApplicationRecord
  belongs_to :lecture
  has_one_attached :file

  validates :content, presence: true
  validates :role, presence: true
end
