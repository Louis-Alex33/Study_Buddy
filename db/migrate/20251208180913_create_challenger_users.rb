class CreateChallengerUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :challenger_users do |t|
      t.references :challenge, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
