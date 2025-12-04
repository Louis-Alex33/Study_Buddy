class NotesController < ApplicationController
  def create
     @note = Note.new(lecture_params)
     @note.save
  end
end
