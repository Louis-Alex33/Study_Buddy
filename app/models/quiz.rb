class Quiz < ApplicationRecord
  belongs_to :category
  has_many :questions, dependent: :destroy
  has_many :attempts, dependent: :destroy
  has_many :challenges, dependent: :destroy
  

  validates :title, presence: true
  validates :level, presence: true, inclusion: { in: 1..5 }
  validates :status, presence: true, inclusion: { in: %w[private public shared] }

  scope :by_difficulty, -> { order(:level) }
end
