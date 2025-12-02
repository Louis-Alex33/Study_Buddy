class UploadsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :create]

  def index
    @uploads = Dir.glob(Rails.root.join('public', 'uploads', '*')).map do |file|
      {
        name: File.basename(file),
        size: File.size(file),
        path: "/uploads/#{File.basename(file)}"
      }
    end
  end

  def create
    uploaded_file = params[:document]
    if uploaded_file
      file_path = Rails.root.join('public', 'uploads', uploaded_file.original_filename)
      FileUtils.mkdir_p(Rails.root.join('public', 'uploads'))
      File.open(file_path, 'wb') do |file|
        file.write(uploaded_file.read)
      end
      redirect_to root_path, notice: "Fichier uploadé avec succès !"
    else
      redirect_to root_path, alert: "Veuillez sélectionner un fichier"
    end
  end
end
