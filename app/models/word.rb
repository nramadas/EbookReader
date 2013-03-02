class Word < ActiveRecord::Base
  attr_accessible :value

  def self.add(value)
    word = Word.find_by_value(value)
    if word
      return word
    else
      return Word.create(value: value)
    end
  end
end
