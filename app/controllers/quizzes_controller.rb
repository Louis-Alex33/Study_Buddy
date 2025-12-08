class QuizzesController < ApplicationController
  before_action :set_lecture, only: [:new, :create]

  def new
  end

  def create
    generated_quiz = generate_quiz_with_ai

    if generated_quiz.present?
      redirect_to lecture_path(@lecture), notice: "Quiz de validation généré avec succès"
    else
      redirect_to lecture_path(@lecture), alert: "Erreur lors de la génération du quiz"
    end
  end

  def show
    @quiz = Quiz.find(params[:id])
    @progress = @quiz.status || 0
  end

  def update_progress
    @quiz = Quiz.find(params[:id])
    @quiz.status = params[:progress]
    @quiz.save
    head :ok
  end

  def destroy
    @quiz = Quiz.find(params[:id])
    lecture = @quiz.lecture
    @quiz.destroy
    redirect_to lecture_path(lecture), notice: "Quiz supprimé avec succès"
  end

  private

  def set_lecture
    @lecture = Lecture.find(params[:lecture_id])
  end

  def generate_quiz_with_ai
    ruby_llm_chat = RubyLLM.chat

    prompt = <<~PROMPT
      Génère 10 questions de validation à partir de cette lecture pour tester la compréhension de l'étudiant:

      Titre: #{@lecture.title}
      Résumé: #{@lecture.resume}

      IMPORTANT: Ces questions doivent être des questions de VALIDATION pour tester si l'étudiant a bien compris la leçon.
      Les questions doivent être plus approfondies que de simples questions de révision.

      Format ta réponse EXACTEMENT comme ceci (une question par bloc):

      Q: [question ici]
      R: [réponse attendue ici]
      ---

      Assure-toi de bien séparer chaque question par "---"
    PROMPT

    response = ruby_llm_chat.ask(prompt)
    quiz_text = response.content
    question_blocks = quiz_text.split("---").map(&:strip).reject(&:empty?)
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

    if questions_data.any?
      quiz = @lecture.quizzes.create(
        content: questions_data.to_json,
        status: 0
      )
      quiz
    else
      nil
    end
  end
end
