class MessagesController < ApplicationController
  before_action :set_lecture

  def create
    @message = @lecture.messages.new(message_params)
    @message.role = "user"
    @message.user = current_user

    if @message.save
      # Créer le message assistant vide
      @assistant_message = @lecture.messages.create!(
        role: "assistant",
        content: "",
        user: current_user
      )

      Rails.logger.info "Created assistant message with ID: #{@assistant_message.id}"

      # Broadcaster d'abord les messages vides via Turbo Stream
      Turbo::StreamsChannel.broadcast_append_to(
        @lecture,
        target: "chat-messages",
        partial: "messages/message",
        locals: { message: @message }
      )

      Turbo::StreamsChannel.broadcast_append_to(
        @lecture,
        target: "chat-messages",
        partial: "messages/message",
        locals: { message: @assistant_message }
      )

      # Faire le streaming (synchrone) qui mettra à jour via broadcasts
      stream_ai_response_with_broadcast(@message, @assistant_message, @lecture)

      # Finalement, rendre une réponse minimale (la page est déjà à jour via broadcasts)
      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { redirect_to lecture_path(@lecture), notice: "Message envoye" }
      end
    else
      respond_to do |format|
        format.html { redirect_to lecture_path(@lecture), alert: "Erreur lors de l'envoi du message" }
      end
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
    - Répondre DIRECTEMENT aux questions posées par l'étudiant
    - Expliquer les concepts difficiles avec des exemples concrets
    - Aider à la compréhension et à la mémorisation
    - Proposer des exercices ou des moyens mnémotechniques si demandé
    - Rester factuel et basé sur le contenu du cours

    CONTRAINTES IMPORTANTES :
    - Réponds toujours en français
    - Réponds DIRECTEMENT à la question posée, ne crée PAS de sommaire ou de table des matières
    - Ne structure PAS ta réponse sous forme de plan avec des sections numérotées sauf si explicitement demandé
    - Sois concis mais complet dans ta réponse
    - Si tu ne connais pas la réponse basée sur le cours, dis-le honnêtement
    - N'invente jamais d'informations
    - Utilise un ton amical et encourageant
    - Commence ta réponse directement par le contenu, pas par une introduction générique"
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
          reader = PDF::Reader.new(@message.file.url)
          text = reader.pages.map(&:text).join('\n')
          build_conversation_history(chat)
          chat.with_instructions(instructions)
          chat.ask(@message.content, with: { pdf: text }).content
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

  def stream_ai_response_with_broadcast(message, assistant_message, lecture)
    ruby_llm_chat = RubyLLM.chat

    # Reconstruire l'historique des conversations (en excluant le message assistant vide qu'on vient de créer)
    lecture.messages.where.not(id: assistant_message.id).order(:created_at).each do |msg|
      # Ne pas ajouter les messages avec un contenu vide
      next if msg.content.blank?
      ruby_llm_chat.add_message(role: msg.role, content: msg.content)
    end

    accumulated_content = ""
    chunk_counter = 0
    last_update_time = Time.now

    begin
      if message.file.attached?
        # Pour les fichiers, on ne peut pas streamer facilement
        content = process_file_with_ai_for_thread(ruby_llm_chat, message, lecture)
        assistant_message.update(content: content)

        Turbo::StreamsChannel.broadcast_replace_to(
          lecture,
          target: "message_#{assistant_message.id}",
          partial: "messages/message",
          locals: { message: assistant_message }
        )
      else
        # Streaming pour les messages texte
        Rails.logger.info "Starting streaming for message: #{message.content}"

        instructions_text = build_instructions(lecture)
        ruby_llm_chat.with_instructions(instructions_text).ask(message.content) do |chunk|
          # Extraire le contenu du chunk
          chunk_content = if chunk.is_a?(String)
            chunk
          elsif chunk.respond_to?(:content)
            chunk.content.to_s
          else
            chunk.to_s
          end

          # Ignorer les chunks vides
          next if chunk_content.nil? || chunk_content.empty?

          accumulated_content += chunk_content
          chunk_counter += 1

          # Mettre à jour tous les 3 chunks ou toutes les 0.1 secondes
          time_elapsed = Time.now - last_update_time
          if chunk_counter >= 3 || time_elapsed >= 0.1
            assistant_message.update(content: accumulated_content)

            Turbo::StreamsChannel.broadcast_replace_to(
              lecture,
              target: "message_#{assistant_message.id}",
              partial: "messages/message",
              locals: { message: assistant_message }
            )

            chunk_counter = 0
            last_update_time = Time.now
          end
        end

        # Dernière mise à jour avec le contenu final
        assistant_message.update(content: accumulated_content)
        Turbo::StreamsChannel.broadcast_replace_to(
          lecture,
          target: "message_#{assistant_message.id}",
          partial: "messages/message",
          locals: { message: assistant_message }
        )

        Rails.logger.info "Streaming completed. Total content length: #{accumulated_content.length}"
      end
    rescue => e
      Rails.logger.error "Streaming error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      assistant_message.update(content: "Erreur lors de la génération de la réponse: #{e.message}")
      Turbo::StreamsChannel.broadcast_replace_to(
        lecture,
        target: "message_#{assistant_message.id}",
        partial: "messages/message",
        locals: { message: assistant_message }
      )
    end
  end

  def build_instructions(lecture)
    "Tu es un assistant pédagogique intelligent spécialisé dans l'aide aux études.
    Tu aides les étudiants à comprendre le contenu de leurs cours (la lecture : #{lecture.title}).

    CONTEXTE DU COURS :
    #{lecture.resume.present? ? "Résumé du document : #{lecture.resume}" : "Aucun résumé disponible pour ce cours."}

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
    - Utilise un ton amical et encourageant
    - Réponds en format markdown"
  end

  def process_file_with_ai_for_thread(chat, message, lecture)
    if message.file.content_type == "application/pdf"
      begin
        chat = RubyLLM.chat(model: "gemini-2.0-flash")
        lecture.messages.order(:created_at).each do |msg|
          chat.add_message(role: msg.role, content: msg.content)
        end
        chat.with_instructions(build_instructions(lecture))
        chat.ask(message.content, with: { pdf: message.file.url }).content
      rescue => e
        if quota_error?(e)
          Rails.logger.warn "Gemini quota exceeded, falling back to GPT-4o: #{e.message}"
          chat = RubyLLM.chat(model: "gpt-4o")
          lecture.messages.order(:created_at).each do |msg|
            chat.add_message(role: msg.role, content: msg.content)
          end
          chat.with_instructions(build_instructions(lecture))
          chat.ask(message.content, with: { pdf: message.file.url }).content
        else
          raise e
        end
      end
    elsif message.file.image?
      chat = RubyLLM.chat(model: "gpt-4o")
      lecture.messages.order(:created_at).each do |msg|
        chat.add_message(role: msg.role, content: msg.content)
      end
      chat.with_instructions(build_instructions(lecture))
      chat.ask(message.content, with: { image: message.file.url }).content
    else
      chat.with_instructions(build_instructions(lecture)).ask(message.content).content
    end
  end
end
