class CategoriesController < ApplicationController
  before_action :set_categories, only: %i[update, edit]

  def edit
  end

  def update
  end

  private

  def set_categories
    @categories = Category.all
  end
end
