class QuizRoom < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :quiz_participants, dependent: :destroy
  has_many :users, through: :quiz_participants
  has_many :quiz_questions, dependent: :destroy

  # Catégories disponibles
  CATEGORIES = {
    'Culture Générale' => 'general',
    'Science' => 'science',
    'Informatique' => 'computers',
    'Mathématiques' => 'mathematics',
    'Sports' => 'sports',
    'Géographie' => 'geography',
    'Histoire' => 'history',
    'Politique' => 'politics',
    'Art' => 'art',
    'Animaux' => 'animals',
    'Véhicules' => 'vehicles'
  }.freeze

  DIFFICULTIES = {
    'Facile' => 'easy',
    'Moyen' => 'medium',
    'Difficile' => 'hard'
  }.freeze

  # Statuses: waiting, in_progress, finished
  validates :status, presence: true, inclusion: { in: %w[waiting in_progress finished] }
  validates :max_players, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 10 }
  validates :category, presence: true
  validates :difficulty, presence: true, inclusion: { in: %w[easy medium hard] }

  scope :waiting, -> { where(status: 'waiting') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :finished, -> { where(status: 'finished') }

  def full?
    quiz_participants.count >= max_players
  end

  def can_start?
    status == 'waiting' && quiz_participants.count >= 2
  end

  def start!
    # Générer les questions depuis l'API avant de démarrer
    if quiz_questions.empty?
      TriviaService.generate_questions_for_room(self, count: 10)
    end
    update!(status: 'in_progress', started_at: Time.current)
  end

  def finish!
    update!(status: 'finished', ended_at: Time.current)
  end

  def winner
    quiz_participants.order(score: :desc, finished_at: :asc).first&.user
  end
end
