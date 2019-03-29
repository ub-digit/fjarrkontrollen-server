class RemoveCustomerTypeFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :customer_type, :string
  end
end
