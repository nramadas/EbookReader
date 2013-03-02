class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :value

      t.timestamps
    end
  end
end
