class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @categories = current_user.categories if user_signed_in?
    @categories = Category.all
    @lecture = Lecture.new
  end

  def message_params
    pararms.require(:message).permit(:content,:title)
  end
end
