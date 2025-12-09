class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.where.not(id: current_user.id).order(:first_name, :last_name, :email)
  end

  def show
    @user = User.find(params[:id])
    @completed_attempts = @user.attempts.completed.includes(quiz: :category).order(created_at: :desc)
    @is_friend = current_user.friend_with?(@user)
    @pending_request = current_user.pending_request_with?(@user)
  end
end
