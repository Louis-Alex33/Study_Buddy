class Challenge < ApplicationRecord
  # Associations
  belongs_to :challenger, class_name: 'User'
  belongs_to :opponent, class_name: 'User'
  belongs_to :category, optional: true
  belongs_to :winner, class_name: 'User', optional: true

  # Statuses: pending (en attente), accepted (accepté), in_progress (en cours), completed (terminé), declined (refusé)
  validates :status, presence: true, inclusion: { in: %w[pending accepted in_progress completed declined] }
  validates :challenger_id, presence: true
  validates :opponent_id, presence: true
  validate :challenger_cannot_challenge_self

  # Scopes
  scope :pending, -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :completed, -> { where(status: 'completed') }
  scope :declined, -> { where(status: 'declined') }

  scope :for_user, ->(user) { where('challenger_id = ? OR opponent_id = ?', user.id, user.id) }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def accept!
    update!(status: 'accepted')
  end

  def decline!
    update!(status: 'declined')
  end

  def start!
    update!(status: 'in_progress')
  end

  def complete!(winner_id, challenger_score, opponent_score)
    update!(
      status: 'completed',
      winner_id: winner_id,
      score_challenger: challenger_score,
      score_opponent: opponent_score
    )

    # Récompenser le gagnant avec de l'XP
    winner.progress.add_xp(100) if winner
  end

  def pending?
    status == 'pending'
  end

  def completed?
    status == 'completed'
  end

  def challenger_won?
    completed? && winner_id == challenger_id
  end

  def opponent_won?
    completed? && winner_id == opponent_id
  end

  private

  def challenger_cannot_challenge_self
    if challenger_id == opponent_id
      errors.add(:opponent, "ne peut pas être le même que le challenger")
    end
  end
end
