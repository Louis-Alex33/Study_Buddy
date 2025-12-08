class QuizzesController < ApplicationController
  before_action :authenticate_user!

  def index
    @categories = Category.includes(:quizzes).where.not(quizzes: { id: nil })
    @quizzes_by_category = Quiz.includes(:category, :questions).group_by(&:category)
  end

  def show
    @quiz = Quiz.includes(questions: :options).find(params[:id])
    @questions = @quiz.questions.ordered
    @user_attempts = @quiz.attempts.where(user: current_user).order(created_at: :desc)
    @best_attempt = @user_attempts.completed.order(score: :desc).first
  end
end
