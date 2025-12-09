class CreateUserLeagues < ActiveRecord::Migration[7.1]
  def change
    create_table :user_leagues do |t|
      t.references :user, null: false, foreign_key: true
      t.string :rank, null: false, default: 'iron'
      t.integer :division, null: false, default: 4
      t.integer :points, null: false, default: 0
      t.integer :wins, null: false, default: 0
      t.integer :losses, null: false, default: 0

      t.timestamps
    end

    add_index :user_leagues, :rank
    add_index :user_leagues, [:rank, :division, :points]
  end
end
