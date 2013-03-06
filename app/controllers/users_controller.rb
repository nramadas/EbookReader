class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  # handle_asynchronously :search_dropbox

  def show
    unless user_signed_in?
      redirect_to new_user_session_url
      return
    end

    @user = current_user

    if @user.checking_dropbox != 1
      @user.update_attributes!(checking_dropbox: 1)
      @user.delay.search_dropbox
    end
  end

  def update
    if params[:user] && params[:user][:file]
      book_file = params[:user].delete(:file)

      puts "-"*50
      p book_file
      puts "-"*50

      @book = current_user.add_book(book_file) if book_file
    end
  end

end
