class Category < ApplicationRecord
  belongs_to :user, optional: true
  has_many :lectures

  validates :title, presence: true

  
  CATEGORIES = [
     { title: "Mathématiques"},
     { name: "Physique"},
     { name: "Histoire"},
     { name: "Langues"},
     { name: "Informatique"},
     { name: "Biologie"}
   ]


  def self.categories
    @categories = CATEGORIES
  end

end
