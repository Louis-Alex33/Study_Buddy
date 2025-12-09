class QuizQuestion < ApplicationRecord
  belongs_to :quiz_room

  def wrong_answers_array
    JSON.parse(wrong_answers || '[]')
  end

  def all_answers_shuffled
    ([correct_answer] + wrong_answers_array).shuffle
  end
end
