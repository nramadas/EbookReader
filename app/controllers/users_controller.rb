class UsersController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = current_user
  end

  def update
    if params[:user] && params[:user][:file]
      book_file = params[:user].delete(:file)

      current_user.add_book(book_file) if book_file
    end

    redirect_to user_path(current_user)
  end

end
