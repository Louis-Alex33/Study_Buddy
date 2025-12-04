class MessagesController < ApplicationController
  before_action :set_lecture

  def create
    @message = @lecture.messages.new(message_params)
    @message.role = "user"
    @message.user = current_user

    if @message.save
      response_content = generate_ai_response
      @lecture.messages.create(role: "assistant", content: response_content, user: current_user)
      redirect_to lecture_path(@lecture), notice: "Message envoye"
    else
      redirect_to lecture_path(@lecture), alert: "Erreur lors de l'envoi du message"
    end
  end

  private

  def set_lecture
    @lecture = Lecture.find(params[:lecture_id])
  end

  def message_params
    params.require(:message).permit(:content, :file)
  end

  def generate_ai_response
    ruby_llm_chat = RubyLLM.chat
    build_conversation_history(ruby_llm_chat)

    if @message.file.attached?
      process_file_with_ai(ruby_llm_chat)
    else
      ruby_llm_chat.with_instructions(instructions).ask(@message.content).content
    end
  end

  def build_conversation_history(chat)
    @lecture.messages.order(:created_at).each do |msg|
      chat.add_message(role: msg.role, content: msg.content)
    end
  end

  def instructions
    "Tu es un assistant pédagogique intelligent spécialisé dans l'aide aux études.
    Tu aides les étudiants à comprendre le contenu de leurs cours (la lecture : #{@lecture.title}).

    CONTEXTE DU COURS :
    #{@lecture.resume.present? ? "Résumé du document : #{@lecture.resume}" : "Aucun résumé disponible pour ce cours."}

    TES RESPONSABILITÉS :
    - Répondre aux questions sur le contenu du cours de manière claire et pédagogique
    - Expliquer les concepts difficiles avec des exemples concrets
    - Aider à la compréhension et à la mémorisation
    - Proposer des exercices ou des moyens mnémotechniques si demandé
    - Rester factuel et basé sur le contenu du cours

    CONTRAINTES :
    - Réponds toujours en français
    - Sois concis mais complet
    - Si tu ne connais pas la réponse basée sur le cours, dis-le honnêtement
    - N'invente jamais d'informations
    - Utilise un ton amical et encourageant"
  end

  def process_file_with_ai(chat)
    if @message.file.content_type == "application/pdf"
      # Essayer d'abord avec Gemini, puis fallback sur GPT-4o si quota épuisé
      begin
        chat = RubyLLM.chat(model: "gemini-2.0-flash")
        build_conversation_history(chat)
        chat.with_instructions(instructions)
        chat.ask(@message.content, with: { pdf: @message.file.url }).content
      rescue => e
        if quota_error?(e)
          Rails.logger.warn "Gemini quota exceeded, falling back to GPT-4o: #{e.message}"
          chat = RubyLLM.chat(model: "gpt-4o")
          build_conversation_history(chat)
          chat.with_instructions(instructions)
          chat.ask(@message.content, with: { pdf: @message.file.url }).content
        else
          raise e
        end
      end
    elsif @message.file.image?
      chat = RubyLLM.chat(model: "gpt-4o")
      build_conversation_history(chat)
      chat.with_instructions(instructions)
      chat.ask(@message.content, with: { image: @message.file.url }).content
    else
      chat.with_instructions(instructions).ask(@message.content).content
    end
  end

  def quota_error?(error)
    # Détecte les erreurs de quota (429, "Resource exhausted", etc.)
    error.message.include?("429") ||
    error.message.include?("Resource exhausted") ||
    error.message.include?("quota") ||
    error.message.include?("rate limit")
  end
end

[]
