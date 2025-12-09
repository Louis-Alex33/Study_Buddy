# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Cleaning database..."
Answer.destroy_all
Attempt.destroy_all
Option.destroy_all
Question.destroy_all
Quiz.destroy_all
FlashcardCompletion.destroy_all
Flashcard.destroy_all
Note.destroy_all
Message.destroy_all
Lecture.destroy_all
Category.destroy_all
User.destroy_all

puts "Creating users..."
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

jp = User.create!(
  first_name: "LA",
  last_name: "Richoux",
  email: "la@mail.com",
  password: "secret",
)

jp = User.create!(
  first_name: "Léo",
  last_name: "Gosse",
  email: "leo@mail.com",
  password: "secret",
)

jp = User.create!(
  first_name: "Kamal",
  last_name: "Kaims",
  email: "kamal@mail.com",
  password: "secret",
)

puts "Creating categories..."
categories = {}
Category::CATEGORIES.each do |cat|
  categories[cat] = Category.create!(title: cat)
end

puts "Creating sample lectures..."
# Skip validation for seed lectures (no document required)
lecture1 = Lecture.new(
  title: "Introduction aux Mathematiques",
  resume: "Cours d'introduction aux concepts mathematiques de base",
  user: henry,
  category: categories["Mathématiques"],
)
lecture1.save!(validate: false)

lecture2 = Lecture.new(
  title: "Physique Quantique",
  resume: "Introduction a la mecanique quantique",
  user: jp,
  category: categories["Physique"],
)
lecture2.save!(validate: false)

puts "Creating quizzes..."

# Math Quiz - Level 1
math_quiz_1 = Quiz.create!(
  title: "Bases des Mathematiques",
  level: 1,
  category: categories["Mathématiques"]
)

q1 = Question.create!(quiz: math_quiz_1, title: "Quel est le resultat de 2 + 2 ?", multiple_answers: false, position: 1)
Option.create!(question: q1, content: "3", correct: false)
Option.create!(question: q1, content: "4", correct: true)
Option.create!(question: q1, content: "5", correct: false)
Option.create!(question: q1, content: "22", correct: false)

q2 = Question.create!(quiz: math_quiz_1, title: "Quel est le resultat de 5 x 3 ?", multiple_answers: false, position: 2)
Option.create!(question: q2, content: "8", correct: false)
Option.create!(question: q2, content: "12", correct: false)
Option.create!(question: q2, content: "15", correct: true)
Option.create!(question: q2, content: "53", correct: false)

q3 = Question.create!(quiz: math_quiz_1, title: "Quels nombres sont pairs ?", multiple_answers: true, position: 3)
Option.create!(question: q3, content: "2", correct: true)
Option.create!(question: q3, content: "3", correct: false)
Option.create!(question: q3, content: "4", correct: true)
Option.create!(question: q3, content: "7", correct: false)

# Math Quiz - Level 2
math_quiz_2 = Quiz.create!(
  title: "Algebre Intermediaire",
  level: 2,
  category: categories["Mathématiques"]
)

q4 = Question.create!(quiz: math_quiz_2, title: "Resoudre: x + 5 = 10. Que vaut x ?", multiple_answers: false, position: 1)
Option.create!(question: q4, content: "3", correct: false)
Option.create!(question: q4, content: "5", correct: true)
Option.create!(question: q4, content: "15", correct: false)
Option.create!(question: q4, content: "10", correct: false)

q5 = Question.create!(quiz: math_quiz_2, title: "Quel est le PGCD de 12 et 18 ?", multiple_answers: false, position: 2)
Option.create!(question: q5, content: "2", correct: false)
Option.create!(question: q5, content: "3", correct: false)
Option.create!(question: q5, content: "6", correct: true)
Option.create!(question: q5, content: "36", correct: false)

# Physics Quiz - Level 1
physics_quiz_1 = Quiz.create!(
  title: "Introduction a la Physique",
  level: 1,
  category: categories["Physique"]
)

q6 = Question.create!(quiz: physics_quiz_1, title: "Quelle est l'unite de mesure de la force ?", multiple_answers: false, position: 1)
Option.create!(question: q6, content: "Metre", correct: false)
Option.create!(question: q6, content: "Newton", correct: true)
Option.create!(question: q6, content: "Kilogramme", correct: false)
Option.create!(question: q6, content: "Seconde", correct: false)

q7 = Question.create!(quiz: physics_quiz_1, title: "Quelles sont des formes d'energie ?", multiple_answers: true, position: 2)
Option.create!(question: q7, content: "Energie cinetique", correct: true)
Option.create!(question: q7, content: "Energie potentielle", correct: true)
Option.create!(question: q7, content: "Energie temporelle", correct: false)
Option.create!(question: q7, content: "Energie thermique", correct: true)

q8 = Question.create!(quiz: physics_quiz_1, title: "Quelle est la vitesse de la lumiere approximative ?", multiple_answers: false, position: 3)
Option.create!(question: q8, content: "300 km/s", correct: false)
Option.create!(question: q8, content: "300 000 km/s", correct: true)
Option.create!(question: q8, content: "3 000 000 km/s", correct: false)
Option.create!(question: q8, content: "30 km/s", correct: false)

# History Quiz - Level 1
history_quiz_1 = Quiz.create!(
  title: "Histoire de France",
  level: 1,
  category: categories["Histoire"]
)

q9 = Question.create!(quiz: history_quiz_1, title: "En quelle annee a eu lieu la Revolution francaise ?", multiple_answers: false, position: 1)
Option.create!(question: q9, content: "1689", correct: false)
Option.create!(question: q9, content: "1789", correct: true)
Option.create!(question: q9, content: "1889", correct: false)
Option.create!(question: q9, content: "1799", correct: false)

q10 = Question.create!(quiz: history_quiz_1, title: "Qui etait Napoleon Bonaparte ?", multiple_answers: false, position: 2)
Option.create!(question: q10, content: "Un roi de France", correct: false)
Option.create!(question: q10, content: "Un empereur francais", correct: true)
Option.create!(question: q10, content: "Un president de la Republique", correct: false)
Option.create!(question: q10, content: "Un general anglais", correct: false)

# Informatique Quiz - Level 1
info_quiz_1 = Quiz.create!(
  title: "Bases de la Programmation",
  level: 1,
  category: categories["Informatique"]
)

q11 = Question.create!(quiz: info_quiz_1, title: "Quel langage est utilise pour le developpement web cote client ?", multiple_answers: false, position: 1)
Option.create!(question: q11, content: "Python", correct: false)
Option.create!(question: q11, content: "JavaScript", correct: true)
Option.create!(question: q11, content: "Java", correct: false)
Option.create!(question: q11, content: "C++", correct: false)

q12 = Question.create!(quiz: info_quiz_1, title: "Quels sont des langages de programmation ?", multiple_answers: true, position: 2)
Option.create!(question: q12, content: "Ruby", correct: true)
Option.create!(question: q12, content: "HTML", correct: false)
Option.create!(question: q12, content: "Python", correct: true)
Option.create!(question: q12, content: "CSS", correct: false)

q13 = Question.create!(quiz: info_quiz_1, title: "Que signifie HTML ?", multiple_answers: false, position: 3)
Option.create!(question: q13, content: "Hyper Text Markup Language", correct: true)
Option.create!(question: q13, content: "High Tech Modern Language", correct: false)
Option.create!(question: q13, content: "Home Tool Markup Language", correct: false)
Option.create!(question: q13, content: "Hyperlinks and Text Markup Language", correct: false)

# Informatique Quiz - Level 3
info_quiz_2 = Quiz.create!(
  title: "Algorithmes et Structures de Donnees",
  level: 3,
  category: categories["Informatique"]
)

q14 = Question.create!(quiz: info_quiz_2, title: "Quelle est la complexite temporelle d'une recherche binaire ?", multiple_answers: false, position: 1)
Option.create!(question: q14, content: "O(n)", correct: false)
Option.create!(question: q14, content: "O(log n)", correct: true)
Option.create!(question: q14, content: "O(n²)", correct: false)
Option.create!(question: q14, content: "O(1)", correct: false)

q15 = Question.create!(quiz: info_quiz_2, title: "Quelles structures de donnees utilisent FIFO ou LIFO ?", multiple_answers: true, position: 2)
Option.create!(question: q15, content: "Queue (FIFO)", correct: true)
Option.create!(question: q15, content: "Stack (LIFO)", correct: true)
Option.create!(question: q15, content: "Array", correct: false)
Option.create!(question: q15, content: "Hash Table", correct: false)

puts "Seeding completed!"
puts "Created #{User.count} users"
puts "Created #{Category.count} categories"
puts "Created #{Lecture.count} lectures"
puts "Created #{Quiz.count} quizzes"
puts "Created #{Question.count} questions"
puts "Created #{Option.count} options"
