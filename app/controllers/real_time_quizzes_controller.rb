class RealTimeQuizzesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quiz_room, only: [:show, :join, :leave, :start, :destroy]

  def index
    @available_rooms = QuizRoom.waiting.where.not(id: current_user.quiz_rooms.pluck(:id))
    @my_rooms = current_user.quiz_rooms.where(status: ['waiting', 'in_progress'])
    @finished_rooms = current_user.quiz_rooms.where(status: 'finished').order(ended_at: :desc).limit(10)
  end

  def new
    @quiz_room = QuizRoom.new
  end

  def create
    @quiz_room = QuizRoom.new(quiz_room_params)
    @quiz_room.status = 'waiting'
    @quiz_room.owner = current_user

    if @quiz_room.save
      # Créer automatiquement le participant pour le créateur
      @quiz_room.quiz_participants.create!(user: current_user, score: 0, correct_answers: 0, total_questions: 0)
      redirect_to real_time_quiz_path(@quiz_room), notice: 'Room créée avec succès!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @participant = @quiz_room.quiz_participants.find_by(user: current_user)
    @participants = @quiz_room.quiz_participants.includes(:user)

    if @quiz_room.status == 'in_progress'
      # Charger les questions de la room
      @questions = @quiz_room.quiz_questions.order(:id)
    end
  end

  def join
    if @quiz_room.full?
      redirect_to real_time_quizzes_path, alert: 'Cette room est pleine!'
      return
    end

    if @quiz_room.quiz_participants.exists?(user: current_user)
      redirect_to real_time_quiz_path(@quiz_room), notice: 'Vous êtes déjà dans cette room!'
      return
    end

    @quiz_room.quiz_participants.create!(user: current_user, score: 0, correct_answers: 0, total_questions: 0)

    
    # Broadcaster la mise à jour des participants à tous les joueurs dans la room
    QuizRoomChannel.broadcast_to(@quiz_room, {
      type: 'player_joined',
      participant_count: @quiz_room.quiz_participants.count,
      max_players: @quiz_room.max_players,
      can_start: @quiz_room.can_start?
    })

    redirect_to real_time_quiz_path(@quiz_room), notice: 'Vous avez rejoint la room!'
  end

  def leave
    participant = @quiz_room.quiz_participants.find_by(user: current_user)

    if participant
      participant.destroy

      # Si plus personne dans la room et qu'elle n'a pas commencé, la supprimer
      if @quiz_room.quiz_participants.empty? && @quiz_room.status == 'waiting'
        @quiz_room.destroy
      end

      redirect_to real_time_quizzes_path, notice: 'Vous avez quitté la room'
    else
      redirect_to real_time_quizzes_path, alert: 'Vous n\'êtes pas dans cette room'
    end
  end

  def start
    # Vérifier que seul l'owner peut démarrer le quiz
    unless @quiz_room.owner == current_user
      redirect_to real_time_quiz_path(@quiz_room), alert: 'Seul le créateur de la room peut lancer le quiz!'
      return
    end

    unless @quiz_room.can_start?
      redirect_to real_time_quiz_path(@quiz_room), alert: 'Il faut au moins 2 joueurs pour commencer!'
      return
    end

    @quiz_room.start!

    # Broadcaster à tous les participants que le quiz a démarré
    QuizRoomChannel.broadcast_to(@quiz_room, {
      type: 'quiz_started'
    })

    redirect_to real_time_quiz_path(@quiz_room), notice: 'Le quiz a commencé!'
  end

  def submit_answer
    @quiz_room = QuizRoom.find(params[:id])
    participant = @quiz_room.quiz_participants.find_by(user: current_user)

    if participant
      correct = params[:correct] == 'true' || params[:correct] == true
      old_score = participant.score || 0

      participant.update!(
        total_questions: (participant.total_questions || 0) + 1,
        correct_answers: (participant.correct_answers || 0) + (correct ? 1 : 0)
      )

      # Calculer le score avec bonus de temps
      time_bonus = params[:time_remaining].to_i * 2
      participant.calculate_score(time_bonus: time_bonus)

      points_earned = participant.score - old_score

      # Broadcaster la mise à jour du leaderboard à tous les participants
      QuizRoomChannel.broadcast_to(@quiz_room, {
        type: 'score_update',
        leaderboard: @quiz_room.quiz_participants.includes(:user, user: :user_league).order(score: :desc).map do |p|
          {
            id: p.id,
            user_id: p.user_id,
            display_name: p.user.display_name,
            score: p.score || 0,
            rank: p.user.user_league&.rank || 'iron',
            division: p.user.user_league&.division || 4
          }
        end
      })

      render json: {
        success: true,
        score: participant.score,
        points_earned: points_earned,
        correct: correct
      }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  def finish
    @quiz_room = QuizRoom.find(params[:id])
    participant = @quiz_room.quiz_participants.find_by(user: current_user)

    if participant
      participant.update!(finished_at: Time.current)

      # Si tous les joueurs ont fini, terminer la room
      if @quiz_room.quiz_participants.all?(&:finished?)
        @quiz_room.finish!

        # Classer les participants par score
        ranked_participants = @quiz_room.quiz_participants.order(score: :desc, finished_at: :asc)

        # Attribuer les points selon le classement
        ranked_participants.each_with_index do |p, index|
          position = index + 1
          p.user.ensure_league!

          result = PointsService.award_quiz_room_victory(
            p.user,
            @quiz_room.difficulty,
            position
          )

          # Perdants (position > 3) perdent des LP
          if position > 3
            p.user.user_league&.add_loss_points(10)
          end
        end

        # Broadcaster le résultat final
        QuizRoomChannel.broadcast_to(@quiz_room, {
          type: 'quiz_finished',
          winner: ranked_participants.first.user.display_name
        })
      end

      redirect_to real_time_quiz_path(@quiz_room), notice: 'Quiz terminé!'
    else
      redirect_to real_time_quizzes_path, alert: 'Erreur'
    end
  end

  def destroy
    # Seul l'owner peut supprimer la room, et seulement si elle est terminée
    if @quiz_room.owner != current_user
      redirect_to real_time_quizzes_path, alert: 'Vous ne pouvez pas supprimer cette room!'
      return
    end

    if @quiz_room.status != 'finished'
      redirect_to real_time_quizzes_path, alert: 'Vous ne pouvez supprimer que les rooms terminées!'
      return
    end

    @quiz_room.destroy
    redirect_to real_time_quizzes_path, notice: 'Room supprimée avec succès!'
  end

  private

  def set_quiz_room
    @quiz_room = QuizRoom.find(params[:id])
  end

  def quiz_room_params
    params.require(:quiz_room).permit(:name, :max_players, :category, :difficulty)
  end
end
