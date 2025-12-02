class CategoryController < ApplicationController


  def new
    @category = Category.new
  end

  def create
    @category = Category.new
    @category.user = current_user

    if @category.save
       notice: "Project created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end
  def show
    @category = Category.find(params [:id])
  end
end
