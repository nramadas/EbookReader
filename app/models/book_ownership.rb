class BookOwnership < ActiveRecord::Base
  attr_accessible :user_id, :book_id, :current_chapter, :start_paragraph,
                  :end_paragraph, :start_word, :end_word
  after_initialize :add_properties

  belongs_to :user
  belongs_to :book

  def add_properties
    self.current_chapter ||= 0
    self.start_paragraph ||= 0
    self.end_paragraph ||= 0
    self.start_word ||= 0
    self.end_word ||= 0
  end
end
