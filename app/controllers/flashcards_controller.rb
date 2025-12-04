class FlashcardsController < ApplicationController
  before_action :set_lecture, only: [:new, :create]

  def new
    # L'IA va générer les flashcards automatiquement
  end

  def create
    # Générer les flashcards avec l'IA
    generated_flashcards = generate_flashcards_with_ai

    if generated_flashcards.present?
      redirect_to lecture_path(@lecture), notice: "#{generated_flashcards.count} flashcards generees avec succes"
    else
      redirect_to lecture_path(@lecture), alert: "Erreur lors de la generation des flashcards"
    end
  end

  def show
    @flashcard = Flashcard.find(params[:id])
    @completion = current_user.flashcard_completions.find_or_initialize_by(flashcard: @flashcard)
    @progress = @completion.status.to_i
  end

  def update_progress
    @flashcard = Flashcard.find(params[:id])
    completion = current_user.flashcard_completions.find_or_initialize_by(flashcard: @flashcard)
    completion.status = params[:progress]
    completion.save
    head :ok
  end

  def destroy
    @flashcard = Flashcard.find(params[:id])
    lecture = @flashcard.lecture
    @flashcard.destroy
    redirect_to lecture_path(lecture), notice: "Flashcard supprimee avec succes"
  end

  private

  def set_lecture
    @lecture = Lecture.find(params[:lecture_id])
  end

  def generate_flashcards_with_ai
    ruby_llm_chat = RubyLLM.chat

    prompt = <<~PROMPT
      Génère 10 questions à partir de cette lecture:

      Titre: #{@lecture.title}
      Résumé: #{@lecture.resume}

      Format ta réponse EXACTEMENT comme ceci (une question par bloc):

      Q: [question ici]
      R: [réponse ici]
      ---

      Assure-toi de bien séparer chaque question par "---"
    PROMPT

    response = ruby_llm_chat.ask(prompt)
    flashcards_text = response.content

    # Parser la réponse pour extraire les questions
    question_blocks = flashcards_text.split("---").map(&:strip).reject(&:empty?)
    questions_data = []

    question_blocks.each do |block|
      lines = block.split("\n").map(&:strip)
      question_line = lines.find { |l| l.start_with?("Q:") }
      answer_line = lines.find { |l| l.start_with?("R:") }

      if question_line && answer_line
        questions_data << {
          question: question_line.sub("Q:", "").strip,
          answer: answer_line.sub("R:", "").strip
        }
      end
    end

    # Créer UNE seule flashcard avec toutes les questions en JSON
    if questions_data.any?
      flashcard = @lecture.flashcards.create(
        content: questions_data.to_json,
        expected_answer: "Quiz de 10 questions"
      )
      [flashcard]
    else
      []
    end
  end
end
