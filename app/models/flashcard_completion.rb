class FlashcardCompletion < ApplicationRecord
  belongs_to :user
  belongs_to :flashcard

  validates :status, presence: true
end
