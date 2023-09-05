class AddDefaultManagingGroupToOrderType < ActiveRecord::Migration
  def change
    add_reference :order_types, :default_managing_group, index: true, foreign_key: false
    add_foreign_key :order_types, :managing_groups, column: :default_managing_group_id
  end
end
