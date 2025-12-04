class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @categories = Category.all
    @lecture = Lecture.new
  end

  end
  def message_params
    pararms.require(:message).permit(:content,:title)
  end

end
