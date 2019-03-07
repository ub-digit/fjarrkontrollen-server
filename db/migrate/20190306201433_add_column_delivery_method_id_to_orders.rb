class AddColumnDeliveryMethodIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :delivery_method_id, :integer
  end
end
