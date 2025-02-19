class DropAllTables < ActiveRecord::Migration[7.0]
  def up
    drop_table :registrations if ActiveRecord::Base.connection.table_exists?('registrations')
    drop_table :matches if ActiveRecord::Base.connection.table_exists?('matches')
    drop_table :teams if ActiveRecord::Base.connection.table_exists?('teams')
    drop_table :tournaments if ActiveRecord::Base.connection.table_exists?('tournaments')
    drop_table :users if ActiveRecord::Base.connection.table_exists?('users')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
