class QuizParticipant < ApplicationRecord
  belongs_to :quiz_room
  belongs_to :user


  validates :user_id, uniqueness: { scope: :quiz_room_id, message: "est déjà dans cette room" }

  def calculate_score(time_bonus: 0)
    # Points de base: 100 points par bonne réponse
    base_score = (correct_answers || 0) * 100

    # Bonus de temps: jusqu'à 50 points par question (temps restant * 2, max 30s * 2 = 60 points mais plafonné à 50)
    time_score = [time_bonus, 50].min

    # Score total
    self.score = base_score + time_score
    save
  end

  def accuracy
    return 0 if total_questions.nil? || total_questions.zero?
    ((correct_answers.to_f / total_questions) * 100).round(2)
  end

  def finished?
    finished_at.present?
  end
end
