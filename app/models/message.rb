class Message < ApplicationRecord
  belongs_to :lecture

  validates :content, presence: true
  validates :role, presence: true
end
