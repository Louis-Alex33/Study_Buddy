class MessageController < ApplicationController

  def create
    if @message.save
    @ruby_llm_chat = RubyLLM.chat
    build_conversation_history
    response = @ruby_llm_chat.with_instructions(instructions).ask(@message.content)

    @chat.messages.create(role: "assistant", content: response.content)
    @chat.generate_title_from_first_message
    else
    render "chats/show", status: :unprocessable_entity
    end
  end

  def process_file(file)
    if file.content_type == "application/pdf"
    @ruby_llm_chat = RubyLLM.chat(model: "gemini-2.0-flash")
    build_conversation_history
    @ruby_llm_chat.with_instructions(instructions)
    @response = @ruby_llm_chat.ask(@message.content, with: { pdf: @message.file.url })
    elsif file.image?
    @ruby_llm_chat = RubyLLM.chat(model: "gpt-4o") # vision-capable model
    build_conversation_history
    @ruby_llm_chat.with_instructions(instructions)
    @response = @ruby_llm_chat.ask(@message.content, with: { image: @message.file.url })
    end
  end
end
