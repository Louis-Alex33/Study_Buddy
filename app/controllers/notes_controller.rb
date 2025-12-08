class NotesController < ApplicationController
  def create
    @lecture = Lecture.find(params[:lecture_id])
    @note = Note.new(note_params)
    @note.lecture = @lecture
    @note.user = current_user

    respond_to do |format|
      if @note.save
        format.turbo_stream
        format.html { redirect_to lecture_path(@note.lecture) }
      else
        format.html { render "lectures/show", status: :unprocessable_content }
      end
    end
  end

  def destroy
    @note = Note.find(params[:id])
    @note.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to lecture_path(@note.lecture), status: :see_other }
    end
  end

  private

  def note_params
    params.require(:note).permit(:content)
  end

end
