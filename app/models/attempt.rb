class Attempt < ApplicationRecord
  belongs_to :user
  belongs_to :quiz
  has_many :answers, dependent: :destroy

  scope :completed, -> { where(done: true) }
  scope :in_progress, -> { where(done: false) }

  def calculate_score
    return 0 if answers.empty?

    correct_count = 0
    quiz.questions.each do |question|
      user_answers = answers.where(question: question)
      correct_options = question.correct_options.pluck(:id)

      if question.multiple_answers
        # All correct options must be selected and no incorrect ones
        selected_ids = user_answers.pluck(:option_id)
        correct_count += 1 if selected_ids.sort == correct_options.sort
      else
        # Single answer: the selected option must be correct
        correct_count += 1 if user_answers.any? { |a| correct_options.include?(a.option_id) }
      end
    end

    correct_count
  end

  def total_questions
    quiz.questions.count
  end

  def percentage_score
    return 0 if total_questions.zero?
    (score.to_f / total_questions * 100).round
  end
end
