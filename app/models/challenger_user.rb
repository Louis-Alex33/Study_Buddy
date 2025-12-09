class ChallengerUser < ApplicationRecord
  belongs_to :challenge
  belongs_to :user
end
