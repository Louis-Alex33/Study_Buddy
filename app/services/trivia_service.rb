require 'net/http'
require 'json'
require 'cgi'

class TriviaService
  BASE_URL = 'https://opentdb.com/api.php'

  # Catégories disponibles
  CATEGORIES = {
    'general' => 9,
    'science' => 17,
    'computers' => 18,
    'mathematics' => 19,
    'sports' => 21,
    'geography' => 22,
    'history' => 23,
    'politics' => 24,
    'art' => 25,
    'animals' => 27,
    'vehicles' => 28
  }.freeze

  def self.fetch_questions(amount: 10, category: nil, difficulty: 'hard')
    params = {
      amount: amount,
      difficulty: difficulty,
      type: 'multiple' # Questions à choix multiples
    }

    params[:category] = CATEGORIES[category] if category && CATEGORIES[category]

    uri = URI(BASE_URL)
    uri.query = URI.encode_www_form(params)

    begin
      response = Net::HTTP.get_response(uri)
      data = JSON.parse(response.body)

      if data['response_code'] == 0
        decode_questions(data['results'])
      else
        []
      end
    rescue => e
      Rails.logger.error "Erreur lors de la récupération des questions: #{e.message}"
      []
    end
  end

  def self.decode_questions(results)
    results.map do |q|
      {
        content: CGI.unescapeHTML(q['question']),
        correct_answer: CGI.unescapeHTML(q['correct_answer']),
        wrong_answers: q['incorrect_answers'].map { |a| CGI.unescapeHTML(a) },
        category: CGI.unescapeHTML(q['category']),
        difficulty: q['difficulty']
      }
    end
  end

  # Créer des questions pour une room
  def self.generate_questions_for_room(quiz_room, count: 10)
    # Utiliser la catégorie et la difficulté de la room
    questions_data = fetch_questions(
      amount: count,
      category: quiz_room.category,
      difficulty: quiz_room.difficulty
    )

    questions_data.each do |q_data|
      quiz_room.quiz_questions.create!(
        content: q_data[:content],
        correct_answer: q_data[:correct_answer],
        wrong_answers: q_data[:wrong_answers].to_json,
        category: q_data[:category],
        difficulty: q_data[:difficulty]
      )
    end
  end
end
