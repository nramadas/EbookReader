class BooksController < ApplicationController
  respond_to :html, :json
  def show
    @book = Book.find(params[:id])

    respond_with @book
  end
end
