class CreateQuizRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :quiz_rooms do |t|
      t.string :name
      t.string :status
      t.integer :max_players
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
