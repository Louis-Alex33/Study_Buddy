class Lecture < ApplicationRecord
  belongs_to :category
  has_many :flashcards

  validates :title, presence: true
  validates :resume, presence: true
end
