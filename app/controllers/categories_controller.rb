class CategoriesController < ApplicationController

def index
  @category = Category.all 
end
  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    @category.user = current_user


    if @category.save

    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @category = Category.find(params [:id])
  end

  private

  def category_params
    params.require(:category).permit(:title)
  end
end
