class ReplaceQuizSystemWithNewSchema < ActiveRecord::Migration[7.1]
  def change
    # Drop old quizzes table
    drop_table :quizzes, if_exists: true

    # Create new quizzes table (linked to category, not lecture)
    create_table :quizzes do |t|
      t.string :title, null: false
      t.integer :level, default: 1, null: false
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    # Create questions table
    create_table :questions do |t|
      t.references :quiz, null: false, foreign_key: true
      t.text :title, null: false
      t.boolean :multiple_answers, default: false, null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    # Create options table
    create_table :options do |t|
      t.references :question, null: false, foreign_key: true
      t.string :content, null: false
      t.boolean :correct, default: false, null: false

      t.timestamps
    end

    # Create attempts table
    create_table :attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :quiz, null: false, foreign_key: true
      t.integer :score
      t.boolean :done, default: false, null: false

      t.timestamps
    end

    # Create answers table
    create_table :answers do |t|
      t.references :attempt, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.references :option, null: false, foreign_key: true

      t.timestamps
    end

    # Add indexes for performance
    add_index :quizzes, :level
    add_index :questions, [:quiz_id, :position]
    add_index :attempts, [:user_id, :quiz_id]
    add_index :answers, [:attempt_id, :question_id]
  end
end
