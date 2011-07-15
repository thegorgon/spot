class Api::NotesController < Api::BaseController
  def index
    @notes = PlaceNote.filter(params)
    render :json => @notes
  end
  
  def show
    @note = current_user.notes.find(params[:id])
    render :json => @note    
  end
  
  def create
    @note = current_user.notes.new(params[:note])
    if @note.user != current_user
      head :conflict
    else
      @note.save!
      render :json => @note
    end
  end
  
  def destroy
    @note = current_user.notes.undeleted.find(params[:id])
    @note.destroy
    head :ok
  end
  
  def update
    @note = current_user.notes.undeleted.find(params[:id])
    @note.content = params[:note][:content]
    @note.status_flags = params[:note][:status_flags]
    @note.save!
    render :json => @note
  end
end