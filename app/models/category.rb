class Category < ApplicationRecord
  belongs_to :user, optional: true
  has_many :lectures

  validates :title, presence: true
end
