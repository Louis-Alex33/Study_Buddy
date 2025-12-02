class AiContentGenerator
  def initialize(lecture)
    @lecture = lecture
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def generate_all
    text_content = extract_text_from_document
    return { error: "Impossible d'extraire le texte du document" } if text_content.blank?

    {
      resume: generate_resume(text_content),
      flashcards: generate_flashcards(text_content),
      quiz: generate_quiz(text_content)
    }
  end

  private

  def extract_text_from_document
    return unless @lecture.document.attached?

    file_path = ActiveStorage::Blob.service.path_for(@lecture.document.key)
    content_type = @lecture.document.content_type

    case content_type
    when 'application/pdf'
      extract_from_pdf(file_path)
    when /text\//
      File.read(file_path)
    when /application\/vnd\.openxmlformats-officedocument\.wordprocessingml\.document/
      # Pour .docx, on pourrait utiliser docx gem, mais pour l'instant on gère juste PDF et TXT
      "Format DOCX non supporté pour le moment"
    else
      "Format de fichier non supporté"
    end
  rescue => e
    Rails.logger.error "Erreur lors de l'extraction du texte: #{e.message}"
    nil
  end

  def extract_from_pdf(file_path)
    reader = PDF::Reader.new(file_path)
    text = reader.pages.map(&:text).join("\n")
    text.strip
  rescue => e
    Rails.logger.error "Erreur lors de la lecture du PDF: #{e.message}"
    nil
  end

  def generate_resume(text_content)
    # Limiter le texte si trop long (max 15000 caractères pour éviter les tokens excessifs)
    truncated_text = text_content.truncate(15000, separator: ' ')

    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          {
            role: "system",
            content: "Tu es un assistant pédagogique expert. Ton rôle est de créer des résumés clairs et structurés de cours académiques."
          },
          {
            role: "user",
            content: <<~PROMPT
              Analyse ce cours et crée un résumé complet et structuré.

              Le résumé doit:
              - Identifier les concepts clés
              - Organiser les informations de manière hiérarchique
              - Utiliser des bullet points et sections
              - Être entre 300 et 500 mots
              - Être rédigé en français

              Cours:
              #{truncated_text}
            PROMPT
          }
        ],
        temperature: 0.7,
        max_tokens: 1000
      }
    )

    response.dig("choices", 0, "message", "content")
  rescue => e
    Rails.logger.error "Erreur lors de la génération du résumé: #{e.message}"
    "Erreur lors de la génération du résumé"
  end

  def generate_flashcards(text_content)
    truncated_text = text_content.truncate(15000, separator: ' ')

    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          {
            role: "system",
            content: "Tu es un assistant pédagogique expert en création de flashcards pour la mémorisation active."
          },
          {
            role: "user",
            content: <<~PROMPT
              Crée 10 flashcards basées sur ce cours.

              Format de réponse STRICT (JSON):
              [
                {
                  "question": "Question claire et concise",
                  "answer": "Réponse précise et complète"
                }
              ]

              Règles:
              - Questions variées (définitions, concepts, applications)
              - Réponses précises mais complètes
              - Niveau académique approprié
              - En français

              Cours:
              #{truncated_text}
            PROMPT
          }
        ],
        temperature: 0.8,
        max_tokens: 2000,
        response_format: { type: "json_object" }
      }
    )

    content = response.dig("choices", 0, "message", "content")
    parse_flashcards(content)
  rescue => e
    Rails.logger.error "Erreur lors de la génération des flashcards: #{e.message}"
    []
  end

  def generate_quiz(text_content)
    truncated_text = text_content.truncate(15000, separator: ' ')

    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          {
            role: "system",
            content: "Tu es un assistant pédagogique expert en création de quiz éducatifs."
          },
          {
            role: "user",
            content: <<~PROMPT
              Crée un quiz de 10 questions à choix multiples (QCM) basé sur ce cours.

              Format de réponse STRICT (JSON):
              {
                "questions": [
                  {
                    "question": "Texte de la question",
                    "options": ["Option A", "Option B", "Option C", "Option D"],
                    "correct_answer": 0,
                    "explanation": "Explication de la bonne réponse"
                  }
                ]
              }

              Règles:
              - 4 options par question
              - correct_answer est l'index (0-3) de la bonne réponse
              - Questions de difficulté progressive
              - Explication claire pour chaque réponse
              - En français

              Cours:
              #{truncated_text}
            PROMPT
          }
        ],
        temperature: 0.8,
        max_tokens: 3000,
        response_format: { type: "json_object" }
      }
    )

    content = response.dig("choices", 0, "message", "content")
    parse_quiz(content)
  rescue => e
    Rails.logger.error "Erreur lors de la génération du quiz: #{e.message}"
    { questions: [] }
  end

  def parse_flashcards(json_content)
    data = JSON.parse(json_content)
    flashcards = data["flashcards"] || data["cards"] || []

    flashcards.map do |card|
      {
        question: card["question"],
        answer: card["answer"]
      }
    end
  rescue => e
    Rails.logger.error "Erreur lors du parsing des flashcards: #{e.message}"
    []
  end

  def parse_quiz(json_content)
    JSON.parse(json_content)
  rescue => e
    Rails.logger.error "Erreur lors du parsing du quiz: #{e.message}"
    { questions: [] }
  end
end
