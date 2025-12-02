class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @category = Category.new
  end

  def message_params
    pararms.require(:message).permit(:content,:title)
  end

end
