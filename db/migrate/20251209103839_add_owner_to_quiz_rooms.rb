class AddOwnerToQuizRooms < ActiveRecord::Migration[7.1]
  def change
    # Supprimer les rooms existantes qui n'ont pas d'owner
    QuizRoom.destroy_all

    add_reference :quiz_rooms, :owner, null: false, foreign_key: { to_table: :users }
  end
end
