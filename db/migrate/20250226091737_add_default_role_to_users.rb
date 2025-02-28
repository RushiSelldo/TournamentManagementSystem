class AddDefaultRoleToUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_default :users, :role, "participant"
  end
end
