class AddCategoryAndDifficultyToQuizRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :quiz_rooms, :category, :string
    add_column :quiz_rooms, :difficulty, :string
  end
end
