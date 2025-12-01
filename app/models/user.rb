class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
has_many :categories
has_many :flashcards, through: :flashcard_completions

  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable
validates :first_name, presence: true
validates :last_name, presence: true

  def lectures
    self.categories.map(&:lectures).flatten.uniq
  end

end
