class Category < ApplicationRecord
  has_many :lectures

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
