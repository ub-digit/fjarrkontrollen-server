class AddColumnPositionToManagingGroups < ActiveRecord::Migration
  def change
    add_column :managing_groups, :position, :integer
  end
end
