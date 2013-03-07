class BookOwnershipsController < ApplicationController
  def update
    book_ownership = BookOwnership.find(params[:id])

    book_ownership.update_attributes!(current_chapter: params[:current_chapter],
                                      start_paragraph: params[:start_paragraph],
                                      end_paragraph: params[:end_paragraph],
                                      start_word: params[:start_word],
                                      end_word: params[:end_word])

    render nothing: true
  end
end
