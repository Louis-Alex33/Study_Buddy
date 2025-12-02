class UserProgress < ApplicationRecord
  belongs_to :user

  # Ligues avec leurs seuils XP et couleurs
  LEAGUES = {
    'Débutant' => { min_xp: 0, max_xp: 499, color: '#64748b', icon: 'fa-skull-crossbones', tier: 1 },
    'Apprenti' => { min_xp: 500, max_xp: 1499, color: '#10b981', icon: 'fa-brain', tier: 2 },
    'Étudiant' => { min_xp: 1500, max_xp: 2999, color: '#3b82f6', icon: 'fa-rocket', tier: 3 },
    'Expert' => { min_xp: 3000, max_xp: 4999, color: '#8b5cf6', icon: 'fa-atom', tier: 4 },
    'Maître' => { min_xp: 5000, max_xp: 7499, color: '#f59e0b', icon: 'fa-shield-alt', tier: 5 },
    'Champion' => { min_xp: 7500, max_xp: 9999, color: '#ef4444', icon: 'fa-dragon', tier: 6 },
    'Légende' => { min_xp: 10000, max_xp: Float::INFINITY, color: '#ec4899', icon: 'fa-crown', tier: 7 }
  }.freeze

  # XP rewards
  XP_REWARDS = {
    upload_lecture: 50,
    complete_flashcard: 10,
    create_note: 20,
    daily_login: 15,
    complete_all_flashcards: 100,
    streak_bonus: 25
  }.freeze

  validates :xp, :level, :total_flashcards_completed, :total_notes_created, :streak_days, presence: true
  validates :xp, :level, :total_flashcards_completed, :total_notes_created, :streak_days, numericality: { greater_than_or_equal_to: 0 }

  after_initialize :set_defaults

  # Retourne la ligue actuelle basée sur l'XP
  def current_league
    LEAGUES.find { |_name, data| xp >= data[:min_xp] && xp <= data[:max_xp] }&.first || 'Débutant'
  end

  # Retourne les données de la ligue actuelle
  def league_data
    LEAGUES[current_league]
  end

  # Retourne le prochain niveau
  def next_league
    current_tier = league_data[:tier]
    LEAGUES.find { |_name, data| data[:tier] == current_tier + 1 }&.first
  end

  # XP nécessaire pour la prochaine ligue
  def xp_to_next_league
    return 0 if current_league == 'Légende'
    next_league_data = LEAGUES[next_league]
    next_league_data[:min_xp] - xp
  end

  # Progression dans la ligue actuelle (en %)
  def league_progress_percentage
    return 100 if current_league == 'Légende'

    league_min = league_data[:min_xp]
    league_max = league_data[:max_xp]
    league_range = league_max - league_min + 1

    current_in_league = xp - league_min
    ((current_in_league.to_f / league_range) * 100).round(1)
  end

  # Ajouter de l'XP
  def add_xp(amount, reason = nil)
    old_league = current_league
    self.xp += amount
    self.level = calculate_level

    new_league = current_league

    # Check si on a monté de ligue
    league_up = old_league != new_league

    save!

    {
      xp_gained: amount,
      total_xp: xp,
      level: level,
      league_up: league_up,
      old_league: old_league,
      new_league: new_league,
      reason: reason
    }
  end

  # Calculer le niveau basé sur l'XP (formule progressive)
  def calculate_level
    (Math.sqrt(xp / 10.0)).floor + 1
  end

  # Récompense pour upload de cours
  def reward_upload_lecture
    add_xp(XP_REWARDS[:upload_lecture], 'Upload de cours')
  end

  # Récompense pour complétion de flashcard
  def reward_flashcard_completion
    self.total_flashcards_completed += 1
    add_xp(XP_REWARDS[:complete_flashcard], 'Flashcard complétée')
  end

  # Récompense pour création de note
  def reward_note_creation
    self.total_notes_created += 1
    add_xp(XP_REWARDS[:create_note], 'Note créée')
  end

  # Récompense pour connexion quotidienne
  def reward_daily_login
    today = Date.today
    last_login = updated_at.to_date

    if last_login < today
      if last_login == today - 1
        self.streak_days += 1
        bonus = streak_days >= 7 ? XP_REWARDS[:streak_bonus] : 0
        add_xp(XP_REWARDS[:daily_login] + bonus, "Connexion quotidienne (Série: #{streak_days} jours)")
      else
        self.streak_days = 1
        add_xp(XP_REWARDS[:daily_login], 'Connexion quotidienne')
      end
    end
  end

  # Stats globales
  def stats
    {
      league: current_league,
      level: level,
      xp: xp,
      total_flashcards: total_flashcards_completed,
      total_notes: total_notes_created,
      streak: streak_days,
      league_progress: league_progress_percentage,
      xp_to_next: xp_to_next_league
    }
  end

  private

  def set_defaults
    self.xp ||= 0
    self.level ||= 1
    self.league ||= 'Débutant'
    self.total_flashcards_completed ||= 0
    self.total_notes_created ||= 0
    self.streak_days ||= 0
  end
end
