class Category < ApplicationRecord
  has_many :lectures
  has_many :quizzes

  validates :title, presence: true


  CATEGORIES = [
     "Mathématiques",
     "Physique",
     "Histoire",
     "Langues",
     "Informatique",
     "Biologie"
   ]

end
