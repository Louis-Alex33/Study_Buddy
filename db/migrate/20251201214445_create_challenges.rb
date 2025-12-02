class CreateChallenges < ActiveRecord::Migration[7.1]
  def change
    create_table :challenges do |t|
      t.references :challenger, null: false, foreign_key: { to_table: :users }
      t.references :opponent, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: 'pending'
      t.references :category, null: true, foreign_key: true
      t.references :winner, null: true, foreign_key: { to_table: :users }
      t.integer :score_challenger, default: 0
      t.integer :score_opponent, default: 0

      t.timestamps
    end

    add_index :challenges, [:challenger_id, :opponent_id]
    add_index :challenges, :status
  end
end
