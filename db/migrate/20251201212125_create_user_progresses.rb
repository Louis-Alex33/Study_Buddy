class CreateUserProgresses < ActiveRecord::Migration[7.1]
  def change
    create_table :user_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :league
      t.integer :level
      t.integer :xp
      t.integer :total_flashcards_completed
      t.integer :total_notes_created
      t.integer :streak_days

      t.timestamps
    end
  end
end
