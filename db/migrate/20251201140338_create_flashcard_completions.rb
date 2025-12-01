class CreateFlashcardCompletions < ActiveRecord::Migration[7.1]
  def change
    create_table :flashcard_completions do |t|
      t.string :status
      t.references :user, null: false, foreign_key: true
      t.references :flashcard, null: false, foreign_key: true

      t.timestamps
    end
  end
end
