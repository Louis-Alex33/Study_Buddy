class LecturesController < ApplicationController

  def show
    @lecture = Lecture.find(params[:id])
  end

  def new
    @category = Category.find(params[:category_id])
    @lecture = Lecture.new
  end

  def create
    @category = Category.find(params[:category_id])
    @lecture = @category.lectures.new(lecture_params)

    if @lecture.save
      redirect_to lecture_path(@lecture), notice: "Lecture creee avec succes"
    else
      render :new
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
    params.require(:lecture).permit(:title, :resume)
  end
end
