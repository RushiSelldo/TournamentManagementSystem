class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.integer :tournament_id, null: false, index: true

      t.timestamps
    end

    add_foreign_key :teams, :tournaments
  end
end
