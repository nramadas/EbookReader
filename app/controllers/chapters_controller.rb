class ChaptersController < ApplicationController
  def show
    chapter = Chapter.find(params[:id])

    respond_to do |format|
      format.html { render nothing: true }
      format.json { render json: chapter }
    end
  end
end
