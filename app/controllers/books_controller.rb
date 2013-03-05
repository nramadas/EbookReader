class BooksController < ApplicationController
  respond_to :html, :json
  def show
    @book = Book.find(params[:id])
    @book_ownership = BookOwnership.where(book_id: params[:id], user_id: current_user.id)[0]

    respond_with @book
  end
end
