class Chapter < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :chapter_words
  has_many :words, through: :chapter_words

  def text
    self.words.map {|word| word.value}.join(' ')
  end

  def add_text(text)
    text_words = text.split(" ")
    all_words = Word.all
    words_hash = {}
    all_words.each {|word| words_hash[word.value] = word }

    new_words = {}

    text_result = []

    text_words.each do |word|
      if words_hash[word]
        ChapterWord.create(chapter_id: self.id, word_id: words_hash[word].id)
      elsif new_words[word]
        ChapterWord.create(chapter_id: self.id, word_id: new_words[word].id)
      else
        new_word = Word.add(word)
        new_words[new_word.value] = new_word
        ChapterWord.create(chapter_id: self.id, word_id: new_word.id)
      end
    end
  end

end
