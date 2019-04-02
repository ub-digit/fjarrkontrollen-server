class AddCustomerTypeToOrder < ActiveRecord::Migration
  def change
    add_reference :orders, :customer_type, index: true, foreign_key: true
  end
end
