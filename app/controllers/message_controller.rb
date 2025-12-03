class MessageController < ApplicationController
  before_action :set_lecture

  def create
    @message = @lecture.messages.new(message_params)
    @message.role = "user"

    if @message.save
      response_content = generate_ai_response
      @lecture.messages.create(role: "assistant", content: response_content)
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
    "Tu es un assistant pedagogique. Aide l'etudiant avec sa lecture: #{@lecture.title}. Resume: #{@lecture.resume}"
  end

  def process_file_with_ai(chat)
    if @message.file.content_type == "application/pdf"
      chat = RubyLLM.chat(model: "gemini-2.0-flash")
      build_conversation_history(chat)
      chat.with_instructions(instructions)
      chat.ask(@message.content, with: { pdf: @message.file.url }).content
      elsif @message.file.image?
      chat = RubyLLM.chat(model: "gpt-4o")
      build_conversation_history(chat)
      chat.with_instructions(instructions)
      chat.ask(@message.content, with: { image: @message.file.url }).content
    else
      chat.with_instructions(instructions).ask(@message.content).content
    end
  end
end
