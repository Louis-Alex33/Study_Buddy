class QuizGeneratorService
  def initialize(quiz)
    @quiz = quiz
  end

  def call
    begin
      response = generate_questions
      parsed_response = parse_json_response(response)
      create_questions(parsed_response['questions'])
      true
    rescue => e
      Rails.logger.error "Error generating quiz #{@quiz.id}: #{e.message}"
      false
    end
  end

  private

  def generate_questions
    chat = RubyLLM.chat(model: "gemini-2.0-flash")
    chat.with_instructions(instructions)
    chat.ask("Génère un quiz de #{questions_count} questions sur le thème '#{@quiz.category.title}' avec un niveau de difficulté #{@quiz.level}/5.").content
  end

  def questions_count
    10
  end

  def instructions
    <<~INSTRUCTIONS
      Tu es un générateur de quiz éducatif. Tu dois créer des questions à choix multiples.

      RÈGLES :
      - Génère exactement #{questions_count} questions
      - Niveau de difficulté : #{@quiz.level}/5 (1=très facile, 5=très difficile)
      - Chaque question a exactement 4 options de réponse
      - Une seule option est correcte par question
      - Les questions doivent être variées et pertinentes pour la catégorie

      FORMAT DE SORTIE STRICT (JSON avec guillemets doubles) :
      {
        "questions": [
          {
            "title": "Question 1 ?",
            "options": [
              {"content": "Réponse A", "correct": false},
              {"content": "Réponse B", "correct": true},
              {"content": "Réponse C", "correct": false},
              {"content": "Réponse D", "correct": false}
            ]
          }
        ]
      }

      Renvoie UNIQUEMENT le JSON, sans texte avant ou après.
    INSTRUCTIONS
  end

  def parse_json_response(response)
    json_match = response.match(/\{.*\}/m)
    json_string = json_match ? json_match[0] : response
    JSON.parse(json_string)
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse quiz JSON: #{response}"
    raise e
  end

  def create_questions(questions_data)
    questions_data.each_with_index do |q_data, index|
      question = @quiz.questions.create!(
        title: q_data['title'],
        position: index + 1,
        multiple_answers: false
      )

      q_data['options'].each do |opt_data|
        question.options.create!(
          content: opt_data['content'],
          correct: opt_data['correct']
        )
      end
    end
  end
end
