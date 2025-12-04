class Message < ApplicationRecord
  MAX_USER_MESSAGES = 10
  
  belongs_to :lecture
  belongs_to :user
  has_one_attached :file

  validates :content, presence: true
  validates :role, presence: true
  validate :user_message_limit

  def user_message_limit
    if chat.messages.where(role: "user").count >= MAX_USER_MESSAGES
      errors.add(:content, "You can only send #{MAX_USER_MESSAGES} messages per chat.")
    end
  end
end
