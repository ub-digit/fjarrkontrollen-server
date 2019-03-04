class AddColumnsManagingGroupId < ActiveRecord::Migration
  def change
    add_column :orders, :managing_group_id, :integer
    add_column :users, :managing_group_id, :integer
  end
end
