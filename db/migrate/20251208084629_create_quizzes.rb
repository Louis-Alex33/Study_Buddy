class CreateQuizzes < ActiveRecord::Migration[7.1]
  def change
    create_table :quizzes do |t|
      t.references :lecture, null: false, foreign_key: true
      t.text :content
      t.integer :status

      t.timestamps
    end
  end
end
