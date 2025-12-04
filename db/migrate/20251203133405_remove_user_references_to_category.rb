class RemoveUserReferencesToCategory < ActiveRecord::Migration[7.1]
  def change
    remove_reference :categories, :user, foreign_key: true, index: false
  end
end
