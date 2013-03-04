class BookOwnership < ActiveRecord::Base
  attr_accessible :user_id, :book_id

  belongs_to :user
  belongs_to :book
end
