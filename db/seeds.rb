puts "cleaning database ..."
Category.destroy_all
User.destroy_all

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
