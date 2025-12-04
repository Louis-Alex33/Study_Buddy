class LecturesController < ApplicationController
  def index
    @lectures = current_user.lectures
  end

  def show
    @lecture = Lecture.find(params[:id])
  end

  def new
    @lecture = Lecture.new
  end

  def create
    @lecture = Lecture.new(lecture_params)

    if @lecture.save
      redirect_to lecture_path(@lecture), notice: "Lecture créée avec succès"
    else
      redirect_to root_path, alert: "Erreur lors de la création"
    end
  end

  def edit
    @lecture = Lecture.find(params[:id])
  end

  def update
    @lecture = Lecture.find(params[:id])

    if @lecture.update(lecture_params)
      redirect_to lecture_path(@lecture), notice: "Lecture mise a jour"
    else
      render :edit
    end
  end

  private

  def lecture_params
    params.require(:lecture).permit(:title, :resume, :category_id)
  end
end
