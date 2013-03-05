class BookOwnershipsController < ApplicationController
  def update
    book_ownership = BookOwnership.find(params[:id])

    book_ownership.update_attributes!(current_chapter: params[:current_chapter],
                                      start_paragraph: params[:start_paragraph],
                                      end_paragraph: params[:end_paragraph])

    render nothing: true
  end
end
