class CreateFlashcards < ActiveRecord::Migration[7.1]
  def change
    create_table :flashcards do |t|
      t.text :content
      t.text :expected_answer
      t.references :lecture, null: false, foreign_key: true

      t.timestamps
    end
  end
end
