class QuizRoomChannel < ApplicationCable::Channel
  def subscribed
    quiz_room = QuizRoom.find(params[:quiz_room_id])
    stream_for quiz_room
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    quiz_room = QuizRoom.find(params[:quiz_room_id])

    case data['action']
    when 'answer_submitted'
      # Broadcast score update to all participants
      QuizRoomChannel.broadcast_to(quiz_room, {
        type: 'score_update',
        leaderboard: quiz_room.quiz_participants.includes(:user, user: :user_league).order(score: :desc).map do |p|
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
    end
  end
end
