class PointsService
  # Points de base par difficulté
  BASE_POINTS = {
    'easy' => 10,
    'medium' => 20,
    'hard' => 30
  }.freeze

  # Points de ligue par difficulté (pour UserLeague)
  LEAGUE_POINTS = {
    'easy' => 5,
    'medium' => 10,
    'hard' => 15
  }.freeze

  # Bonus selon le score (pourcentage)
  SCORE_MULTIPLIERS = {
    100 => 2.0,  # Score parfait = x2
    90 => 1.5,   # 90%+ = x1.5
    80 => 1.3,   # 80%+ = x1.3
    70 => 1.2,   # 70%+ = x1.2
    60 => 1.0,   # 60%+ = x1.0
    0 => 0.5     # < 60% = x0.5
  }.freeze

  def self.award_quiz_completion(user, quiz_level, score_percentage)
    difficulty = level_to_difficulty(quiz_level)
    base = BASE_POINTS[difficulty]
    multiplier = calculate_multiplier(score_percentage)

    points = (base * multiplier).round
    league_points = LEAGUE_POINTS[difficulty]

    # Ajouter les points au user
    user.add_points(points)

    # Ajouter les points de ligue
    user.user_league&.add_win_points(league_points)

    {
      points: points,
      league_points: league_points,
      difficulty: difficulty,
      score_percentage: score_percentage
    }
  end

  def self.award_quiz_room_victory(user, difficulty, position)
    # Position 1 = gagnant, 2 = second, etc.
    base = BASE_POINTS[difficulty] || BASE_POINTS['medium']

    # Bonus selon la position
    position_multiplier = case position
    when 1 then 3.0   # Gagnant = x3
    when 2 then 2.0   # Second = x2
    when 3 then 1.5   # Troisième = x1.5
    else 1.0          # Participation
    end

    points = (base * position_multiplier).round
    league_points = (LEAGUE_POINTS[difficulty] || 10) * (position == 1 ? 2 : 1)

    user.add_points(points)
    user.user_league&.add_win_points(league_points) if position <= 3

    {
      points: points,
      league_points: league_points,
      position: position,
      difficulty: difficulty
    }
  end

  def self.award_challenge_completion(user, quiz_level, score_percentage, is_winner)
    difficulty = level_to_difficulty(quiz_level)
    base = BASE_POINTS[difficulty]
    multiplier = calculate_multiplier(score_percentage)

    # Bonus si gagnant du challenge
    winner_bonus = is_winner ? 1.5 : 1.0

    points = (base * multiplier * winner_bonus).round
    league_points = LEAGUE_POINTS[difficulty] * (is_winner ? 2 : 1)

    user.add_points(points)

    if is_winner
      user.user_league&.add_win_points(league_points)
    end

    {
      points: points,
      league_points: is_winner ? league_points : 0,
      difficulty: difficulty,
      is_winner: is_winner,
      score_percentage: score_percentage
    }
  end

  private

  def self.level_to_difficulty(level)
    case level
    when 1 then 'easy'
    when 2 then 'medium'
    when 3..Float::INFINITY then 'hard'
    else 'medium'
    end
  end

  def self.calculate_multiplier(score_percentage)
    SCORE_MULTIPLIERS.each do |threshold, multiplier|
      return multiplier if score_percentage >= threshold
    end
    SCORE_MULTIPLIERS[0]
  end
end
