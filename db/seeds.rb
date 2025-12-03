# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).


puts "clean database..."
Lecture.destroy_all
Category.destroy_all
User.destroy_all

puts "create a new user ...."
henry = User.create!(
  first_name: "Henry",
  last_name: "Thierry",
  email: "henry@mail.com",
  password: "secret",
)

jp = User.create!(
  first_name: "JP",
  last_name: "Ben",
  email: "jp@mail.com",
  password: "secret",
)

  Category::CATEGORIES.each do |cat|
    Category.create!(title: cat)
  end

lecture = Lecture.create!(
  title: "test",
  resume: "lecture content",
  user: henry,
  category: Category.last,
)
