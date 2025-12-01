class Flashcard < ApplicationRecord
  belongs_to :lecture
  has_many :users, through: :flashcard_completions

  validates :content, presence: true
  validates :expected_answer, presence: true
end
