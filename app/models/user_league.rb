class UserLeague < ApplicationRecord
  belongs_to :user

  # League of Legends rank system
  RANKS = %w[iron bronze silver gold platinum emerald diamond master grandmaster challenger].freeze

  # Divisions: 4, 3, 2, 1 (lower number = higher division)
  # Master, Grandmaster, and Challenger don't have divisions
  DIVISIONED_RANKS = %w[iron bronze silver gold platinum emerald diamond].freeze

  validates :rank, presence: true, inclusion: { in: RANKS }
  validates :division, presence: true, inclusion: { in: 1..4 }
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :wins, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :losses, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Rank display names
  RANK_NAMES = {
    'iron' => 'Novice',
    'bronze' => 'Apprenti',
    'silver' => 'Étudiant',
    'gold' => 'Érudit',
    'platinum' => 'Savant',
    'emerald' => 'Expert',
    'diamond' => 'Maître',
    'master' => 'Virtuose',
    'grandmaster' => 'Génie',
    'challenger' => 'Légende'
  }.freeze

  # Rank colors for display
  RANK_COLORS = {
    'iron' => '#4A4A4A',
    'bronze' => '#CD7F32',
    'silver' => '#C0C0C0',
    'gold' => '#FFD700',
    'platinum' => '#00CED1',
    'emerald' => '#50C878',
    'diamond' => '#B9F2FF',
    'master' => '#9B30FF',
    'grandmaster' => '#FF4500',
    'challenger' => '#F4C430'
  }.freeze

  def display_name
    name = RANK_NAMES[rank] || rank.capitalize
    if DIVISIONED_RANKS.include?(rank)
      "#{name} #{division}"
    else
      name
    end
  end

  def rank_color
    RANK_COLORS[rank] || '#000000'
  end

  # Glow intensity based on rank (0-10 scale)
  def glow_intensity
    RANKS.index(rank) || 0
  end

  # Glow class for styling
  def glow_class
    "rank-glow-#{glow_intensity}"
  end

  def win_rate
    total_games = wins + losses
    return 0 if total_games.zero?
    ((wins.to_f / total_games) * 100).round
  end

  def total_games
    wins + losses
  end

  # Add points after winning a game
  def add_win_points(amount = 20)
    self.wins += 1
    self.points += amount

    if points >= 100
      promote
    end

    save
  end

  # Remove points after losing a game
  def add_loss_points(amount = 15)
    self.losses += 1
    self.points -= amount

    if points < 0
      demote
    end

    save
  end

  private

  def promote
    self.points = 0

    if DIVISIONED_RANKS.include?(rank)
      if division > 1
        # Move to next division in same rank
        self.division -= 1
      else
        # Move to next rank
        rank_index = RANKS.index(rank)
        if rank_index && rank_index < RANKS.length - 1
          next_rank = RANKS[rank_index + 1]
          self.rank = next_rank
          self.division = DIVISIONED_RANKS.include?(next_rank) ? 4 : 1
        end
      end
    end
  end

  def demote
    self.points = 75

    if DIVISIONED_RANKS.include?(rank)
      if division < 4
        # Move to previous division in same rank
        self.division += 1
      else
        # Move to previous rank
        rank_index = RANKS.index(rank)
        if rank_index && rank_index > 0
          previous_rank = RANKS[rank_index - 1]
          self.rank = previous_rank
          self.division = 1
        else
          # Can't go lower than Iron 4
          self.points = 0
        end
      end
    elsif rank != 'iron'
      # If in Master+, demote to Diamond 1
      self.rank = 'diamond'
      self.division = 1
    end
  end
end
