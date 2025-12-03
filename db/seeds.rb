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
Lectrure.destroy_all
Category.destroy_all
User.destroy_all
Puts "Cleaning database..."

test_user = User.create(
  first_name: "test",
  last_name: "test",
  password: "azerty",
  email: "test@test.test"
)

cat = Category.create(
  user: User.last,
  title: "cat test"
)

lecture = Lecture.new(
  title: "test",
  category: Category.last,
  resume: "test"
)

lecture.document.attach(
  io: File.open("public/images/homepage_banner.jpg"),
  filename: "banner.jpg",
  content_type: "image/jpg"
)

lecture.save!


# blob = ActiveStorage::Blob.create_and_upload!(
#   io: File.open("public/images/homepage_banner.jpg"),
#   filename: "homepage_banner.jpg",
#   content_type: "image/jpeg"
# )

# p blob.url