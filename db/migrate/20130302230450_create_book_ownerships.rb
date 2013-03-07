class CreateBookOwnerships < ActiveRecord::Migration
  def change
    create_table :book_ownerships do |t|
      t.integer :book_id
      t.integer :user_id
      t.integer :current_chapter
      t.integer :start_paragraph
      t.integer :end_paragraph
      t.integer :start_word
      t.integer :end_word

      t.timestamps
    end
  end
end
