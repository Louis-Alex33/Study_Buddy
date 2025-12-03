class AddUserReferenceToLectures < ActiveRecord::Migration[7.1]
  def change
    add_reference :lectures, :user, null: false, foreign_key: true
  end
end
