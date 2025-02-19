class CreateTeamMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :team_members do |t|
      t.integer :team_id, null: false, index: true
      t.integer :user_id, null: false, index: true
      t.string :role, null: false
      t.timestamp :joined_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end

    add_foreign_key :team_members, :teams
    add_foreign_key :team_members, :users, column: :user_id
  end
end
