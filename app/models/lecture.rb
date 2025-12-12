class Lecture < ApplicationRecord
  MAX_FILE_SIZE_MB  = 10

  has_one_attached :document

  belongs_to :user
  belongs_to :category
  has_many :flashcards, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :notes

  validates :title, presence: true
  validates :category, presence: true

  validate :document_presence
  validate :file_size_limit

  after_commit :analyze_document, on: :create


  def document_presence
    errors.add(:document, "must be attached") unless document.attached?
  end

  def file_size_limit
    if document.attached? && document.byte_size > MAX_FILE_SIZE_MB.megabytes
      errors.add(:document, "size must be less than #{MAX_FILE_SIZE_MB}MB")
    end
  end

  private

  def analyze_document
    LectureAnalyzerService.new(self).call
  end
end
