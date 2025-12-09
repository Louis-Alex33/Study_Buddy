class CreateQuizQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :quiz_questions do |t|
      t.text :content
      t.string :correct_answer
      t.text :wrong_answers
      t.string :category
      t.string :difficulty
      t.references :quiz_room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
