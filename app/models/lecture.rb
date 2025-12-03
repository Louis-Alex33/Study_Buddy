class Lecture < ApplicationRecord
  has_one_attached :document
  
  belongs_to :user
  belongs_to :category
  has_many :flashcards
  has_many :messages, dependent: :destroy

  validates :title, presence: true
  validates :resume, presence: true

  def after_create
    # récupèrer le file.attachement
    # créer une lecture affiliée à ce fichier (résumé)
  end

end
