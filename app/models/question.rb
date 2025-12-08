class Question < ApplicationRecord
  belongs_to :quiz
  has_many :options, dependent: :destroy
  has_many :answers

  validates :title, presence: true
  validates :position, presence: true

  scope :ordered, -> { order(:position) }

  def correct_options
    options.where(correct: true)
  end
end
