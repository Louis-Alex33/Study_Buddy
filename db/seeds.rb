# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#

puts "Cleaning database..."
Lecture.destroy_all
Category.destroy_all
User.destroy_all

test_user = User.create(
  first_name: "JP",
  last_name: "Ben",
  password: "azerty",
  email: "test@test.test"
)


# lecture.document.attach(
#   io: File.open("public/images/homepage_banner.jpg"),
#   filename: "banner.jpg",
#   content_type: "image/jpg"
# )

# lecture.save!


# blob = ActiveStorage::Blob.create_and_upload!(
#   io: File.open("public/images/homepage_banner.jpg"),
#   filename: "homepage_banner.jpg",
#   content_type: "image/jpeg"
# )

# p blob.url

puts "create a new user ...."
henry = User.create!(
  first_name: "Henry",
  last_name: "Thierry",
  email: "henry@mail.com",
  password: "secret",
)

category_1 = Category.create!(
  title: "Droit",
  user: henry,
  created_at: "2025-11-01",
)
category_2 = Category.create!(
  title: "Anatomie",
  user: henry,
  created_at: "2025-11-01",
)
category_3 = Category.create!(
  title: "Informatique",
  user: henry,
  created_at: "2024-03-11",
)

category_4 = Category.create!(
  title: "Robotique",
  user: henry,
  created_at: "2024-03-12",
)

category_5 = Category.create!(
  title: "Environnement",
  user: henry,
  created_at: "2025-06-12",
)

category_6 = Category.create!(
  title: "Génie civil",
  user: henry,
  created_at: "2023-02-29",
)

lecture = Lecture.create!(
  title: "Test",
  category: category_1,
  resume: "Ceci est un cours test"
)