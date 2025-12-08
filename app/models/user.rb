class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :lectures
  has_many :categories, through: :lectures
  has_many :flashcard_completions
  has_many :flashcards, through: :flashcard_completions
  has_many :attempts

  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable
# validates :first_name, presence: true
# validates :last_name, presence: true

end
