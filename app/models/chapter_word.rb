class ChapterWord < ActiveRecord::Base
  attr_accessible :chapter_id, :word_id
  belongs_to :chapter
  belongs_to :word

end
