class CreateMatches < ActiveRecord::Migration[7.0]
  def change
    create_table :matches do |t|
      t.integer :tournament_id, null: false, index: true
      t.integer :team_1_id, null: false, index: true
      t.integer :team_2_id, null: false, index: true
      t.timestamp :scheduled_at, null: false
      t.integer :score_team_1, null: false, default: 0
      t.integer :score_team_2, null: false, default: 0

      t.timestamps
    end

    add_foreign_key :matches, :tournaments
    add_foreign_key :matches, :teams, column: :team_1_id
    add_foreign_key :matches, :teams, column: :team_2_id
  end
end
