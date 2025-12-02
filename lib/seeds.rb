# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Creating test user..."
user = User.find_or_create_by!(email: "test@example.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
  u.first_name = "Test"
  u.last_name = "User"
end
puts "User created: #{user.email}"

puts "\nCreating categories..."
categories = [
  "Mathématiques",
  "Physique",
  "Chimie",
  "Biologie",
  "Histoire",
  "Géographie",
  "Langues",
  "Informatique",
  "Économie",
  "Philosophie"
]

categories.each do |category_name|
  Category.find_or_create_by!(title: category_name, user: user)
  puts "- #{category_name}"
end

puts "\n✅ Seed completed!"
