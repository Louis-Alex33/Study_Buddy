class Lecture < ApplicationRecord
  MAX_FILE_SIZE_MB  = 10
  
  has_one_attached :document
  
  belongs_to :user
  belongs_to :category
  belongs_to :user
  has_many :flashcards
  has_many :messages, dependent: :destroy

  validates :title, presence: true
  validates :resume, presence: true
  validates :category, presence: true
  validates :document, presence: true
  
  validate :file_size_limit

  def after_create
    # récupèrer le file.attachement
    # créer une lecture affiliée à ce fichier (résumé)
  end


  def file_size_limit
    if document.attached? && document.byte_size > MAX_FILE_SIZE_MB.megabytes
      errors.add(:document, "size must be less than #{MAX_FILE_SIZE_MB}MB")
    end
  end

end
