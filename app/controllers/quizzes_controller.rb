class QuizzesController < ApplicationController
  before_action :authenticate_user!

  def index
    @categories = Category.includes(:quizzes).where.not(quizzes: { id: nil })
    @public_quizzes = Quiz.where(status: "public").includes(:category, :questions, :attempts).group_by(&:category)
    @shared_quizzes = Quiz.where(status: "shared").includes(:category, :questions, :attempts, challenges: [:user, :invited_users]).group_by(&:category)
  end

  def show
    @quiz = Quiz.includes(questions: :options).find(params[:id])
    @questions = @quiz.questions.ordered
    @user_attempts = @quiz.attempts.where(user: current_user).order(created_at: :desc)
    @best_attempt = @user_attempts.completed.order(score: :desc).first
  end

  def new
    @quiz = Quiz.new
  end

  def create
    @quiz = Quiz.new(quiz_params)

    if @quiz.save
      # Générer les questions avec l'IA
      QuizGeneratorService.new(@quiz).call

      # Créer le challenge avec l'utilisateur courant comme propriétaire
      challenge = current_user.challenges.create!(quiz: @quiz)

      # Ajouter les amis invités au challenge (seulement si quiz shared)
      if @quiz.status == "shared" && params[:invited_user_ids].present?
        params[:invited_user_ids].each do |user_id|
          challenge.challenger_users.create!(user_id: user_id)
        end
      end

      redirect_to challenges_path, notice: "Défi créé avec succès !"
    else
      redirect_to challenges_path, alert: "Erreur lors de la création du défi."
    end
  end

  private

  def quiz_params
    params.require(:quiz).permit(:title, :category_id, :level, :status)
  end
end
