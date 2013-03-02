class CreateChapterWords < ActiveRecord::Migration
  def change
    create_table :chapter_words do |t|
      t.integer :word_id
      t.integer :chapter_id

      t.timestamps
    end
  end
end
