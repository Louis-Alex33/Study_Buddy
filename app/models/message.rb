class Message < ApplicationRecord
  belongs_to :lecture
  belongs_to :user
  has_one_attached :file

  validates :content, presence: true
  validates :role, presence: true
end
