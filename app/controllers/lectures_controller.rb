class LecturesController < ApplicationController

  def index
    @lectures = current_user.lectures
  end

  def show
    @lecture = Lecture.find(params[:id])
    @note = Note.new
  end

  def new
    @lecture = Lecture.new
  end

  def create
    @lecture = Lecture.new(lecture_params)
    @lecture.user = current_user

    if @lecture.save
      redirect_to lecture_path(@lecture), notice: "Lecture créée avec succès"
    else
      render "pages/home", status: :unprocessable_content
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
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @lecture = Lecture.find(params[:id])
    @lecture.destroy
    redirect_to lectures_path, notice: "Lecture supprimée avec succès"
  end

  private

  def lecture_params
    params.require(:lecture).permit(:title, :resume, :category_id, :document)
  end
end
