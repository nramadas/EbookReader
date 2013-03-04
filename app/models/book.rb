class Book < ActiveRecord::Base
  attr_accessible :hash_identifier, :title

  has_many :chapters
  has_many :book_ownerships
  has_many :users, through: :book_ownerships

  def as_json(options = {})
    {
      title: title,
      chapter_ids: chapters.map { |c| c.id }
    }
  end

  def self.generate(file)
    checksum = Digest::SHA256.hexdigest(file.read)

    existing_book = Book.find_by_hash_identifier(checksum)

    return existing_book if existing_book

    chapters = []

    book = EPUB::Parser.parse(file.tempfile.to_path.to_s)
    book.each_page_on_spine do |chapter|
      next if chapter.id == "titlepage"
      chapter = Nokogiri::HTML(chapter.read)

      chapter = chapter.at_css("body").inner_html
                                      .strip
                                      .gsub("\n", "")
                                      .gsub("\"", "&quot;")
                                      .gsub(/<a(.*?)>/, "")
                                      .gsub("</a>", "")
                                      .gsub(/<img(.*?)>/, "")
                                      .gsub("<br>", "")

      next if chapter.empty?

      chapters << Chapter.add(chapter)
    end

    new_book = Book.create(hash_identifier: checksum, title: book.title)
    new_book.chapters = chapters

    new_book
  end
end
