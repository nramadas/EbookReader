class Chapter < ActiveRecord::Base
  attr_accessible :text

  def self.add(text)
    self.create(text: text)
  end
end
