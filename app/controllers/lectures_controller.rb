class LecturesController < ApplicationController

  def index
    
  end

  def new
    @lecture = Lecture.new
  end

  def create
    @lecture = Lecture.new(lecture_params)
    @lecture.user = current_user

    if @lecture.save
    else 
      render :new, status: :unprocessable_entity
    end
  end

  private

  def lecture_params
    pararms.require(:lecture).permit(
  :title,
  :resume
  )
  end
end
