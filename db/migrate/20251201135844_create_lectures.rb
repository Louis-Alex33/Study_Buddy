class CreateLectures < ActiveRecord::Migration[7.1]
  def change
    create_table :lectures do |t|
      t.string :title
      t.text :resume
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
