class CreateTournaments < ActiveRecord::Migration[7.0]
  def change
    create_table :tournaments do |t|
      t.string :name, null: false
      t.string :location, null: false
      t.date :start_date, null: false
      t.integer :host_id, null: false, index: true

      t.timestamps
    end

    add_foreign_key :tournaments, :users, column: :host_id
  end
end
