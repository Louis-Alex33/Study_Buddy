class AttemptsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quiz
  before_action :set_attempt, only: [:show, :submit]

  def create
    @attempt = @quiz.attempts.create!(user: current_user, done: false)
    redirect_to quiz_attempt_path(@quiz, @attempt)
  end

  def show
    @questions = @quiz.questions.includes(:options).ordered
    @existing_answers = @attempt.answers.index_by(&:question_id)
  end

  def submit
    if @attempt.done?
      redirect_to quiz_attempt_path(@quiz, @attempt), alert: "Ce quiz a déjà été soumis."
      return
    end

    # Clear existing answers and save new ones
    @attempt.answers.destroy_all

    answers_params = params[:answers] || {}
    answers_params.each do |question_id, option_ids|
      Array(option_ids).each do |option_id|
        next if option_id.blank?
        @attempt.answers.create!(
          question_id: question_id,
          option_id: option_id
        )
      end
    end

    # Calculate and save score
    @attempt.update!(
      score: @attempt.calculate_score,
      done: true
    )

    redirect_to quiz_attempt_path(@quiz, @attempt), notice: "Quiz terminé ! Score: #{@attempt.score}/#{@attempt.total_questions}"
  end

  private

  def set_quiz
    @quiz = Quiz.find(params[:quiz_id])
  end

  def set_attempt
    @attempt = @quiz.attempts.find(params[:id])

    # Ensure user can only access their own attempts
    unless @attempt.user == current_user
      redirect_to quizzes_path, alert: "Accès non autorisé."
    end
  end
end
