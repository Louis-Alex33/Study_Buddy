class Challenge < ApplicationRecord
  belongs_to :user
  belongs_to :quiz
  has_many :challenger_users, dependent: :destroy
  has_many :invited_users, through: :challenger_users, source: :user
end
