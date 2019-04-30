class AddKohaBorrowernumberToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :koha_borrowernumber, :integer
  end
end
