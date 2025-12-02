class Lecture < ApplicationRecord
  has_one_attached :document
  
  belongs_to :category
  has_many :flashcards

  validates :title, presence: true
  validates :resume, presence: true

  def after_create
    # récupèrer le file.attachement
    # créer une lecture affiliée à ce fichier (résumé)
  end

end
