class ChallengesController < ApplicationController

  def index
    @quiz = Quiz.new
    @challenge = current_user.challenges.new

    # Challenges créés par l'utilisateur
    @my_challenges = current_user.challenges.includes(quiz: [:category, :questions])

    # Challenges où l'utilisateur est invité
    @invited_challenges = current_user.invited_challenges.includes(:user, quiz: [:category, :questions])
  end
end
