class Answer < ApplicationRecord
  belongs_to :attempt
  belongs_to :question
  belongs_to :option

  validates :option_id, uniqueness: { scope: [:attempt_id, :question_id] }
end
