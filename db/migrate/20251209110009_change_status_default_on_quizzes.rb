class ChangeStatusDefaultOnQuizzes < ActiveRecord::Migration[7.1]
  def up
    change_column_default :quizzes, :status, from: "private", to: "shared"
    Quiz.where(status: "private").update_all(status: "shared")
  end

  def down
    change_column_default :quizzes, :status, from: "shared", to: "private"
  end
end
