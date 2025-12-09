class AddStatusToQuizzes < ActiveRecord::Migration[7.1]
  def change
    add_column :quizzes, :status, :string, default: "private", null: false
  end
end
