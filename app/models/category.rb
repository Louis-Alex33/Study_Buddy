class Category < ApplicationRecord
  belongs_to :user
  has_many :lectures

  validates :title, presence: true
end
