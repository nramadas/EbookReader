require 'dropbox_sdk'

class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [:show]

  def show
    unless user_signed_in?
      redirect_to new_user_session_url
      return
    end

    @user = current_user
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

  def search_dropbox
    @user = current_user

    if @user.provider == "dropbox"
      dbsession = DropboxSession.new("j5zlax407wga81i", "e6rctl0ix6n8y4t")

      token = @user.dropbox_token
      secret = @user.dropbox_secret

      dbsession.set_access_token(token, secret)
      client = DropboxClient.new(dbsession)

      client.metadata('/')['contents'].each do |file|
        content = client.get_file(file["path"])

        File.open('book.epub', 'wb') {|f| f.puts content}
        book = File.open('book.epub')

        book = ActionDispatch::Http::UploadedFile.new({
          filename: file["path"],
          headers: "blank",
          content_type: "blank",
          tempfile: book
          })

        @book = @user.add_book(book)
      end
    end

    render nothing: true
  end

end
