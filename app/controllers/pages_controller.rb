class PagesController < ApplicationController
  MAX_FILE_SIZE_MB = 10

  skip_before_action :authenticate_user!, only: [ :home ]
  skip_before_action :verify_authenticity_token, only: [ :cheat_points ]

  def home
    @categories = Category.all
    @lecture = Lecture.new
  end

  def cheat_points
    return render json: { success: false }, status: :unauthorized unless user_signed_in?

    points_to_add = params[:points].to_i
    points_to_add = 50 if points_to_add <= 0 # Default to 50 if invalid

    # Add points to user
    current_user.add_points(points_to_add)

    # Update league points (add_win_points adds 20 LP by default)
    if current_user.user_league
      current_user.user_league.add_win_points(25)
    else
      current_user.ensure_league!
      current_user.user_league.add_win_points(25)
    end

    render json: {
      success: true,
      points_added: points_to_add,
      new_points: current_user.points,
      league_points: current_user.user_league&.points,
      league: current_user.user_league&.display_name
    }
  end

  def message_params
    pararms.require(:message).permit(:content,:title)
  end

end
