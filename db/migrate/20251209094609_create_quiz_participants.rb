class CreateQuizParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :quiz_participants do |t|
      t.references :quiz_room, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :score
      t.integer :correct_answers
      t.integer :total_questions
      t.datetime :finished_at

      t.timestamps
    end
  end
end
