class GenerateAiContentJob < ApplicationJob
  queue_as :default

  def perform(lecture_id)
    lecture = Lecture.find(lecture_id)
    generator = AiContentGenerator.new(lecture)

    Rails.logger.info "Génération du contenu IA pour la lecture #{lecture.id}..."

    result = generator.generate_all

    if result[:error]
      Rails.logger.error "Erreur IA: #{result[:error]}"
      return
    end

    # Mettre à jour le résumé de la lecture
    lecture.update(resume: result[:resume]) if result[:resume]

    # Créer les flashcards
    if result[:flashcards].present?
      result[:flashcards].each do |flashcard_data|
        lecture.flashcards.create(
          question: flashcard_data[:question],
          answer: flashcard_data[:answer]
        )
      end
      Rails.logger.info "#{result[:flashcards].count} flashcards créées"
    end

    # Créer le quiz
    if result[:quiz].present? && result[:quiz][:questions].present?
      lecture.create_quiz(questions: result[:quiz][:questions])
      Rails.logger.info "Quiz créé avec #{result[:quiz][:questions].count} questions"
    end

    Rails.logger.info "Génération du contenu IA terminée pour la lecture #{lecture.id}"
  rescue => e
    Rails.logger.error "Erreur lors de la génération du contenu IA: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end
