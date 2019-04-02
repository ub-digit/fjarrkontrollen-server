class AddAuthenticatedXAccountToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :authenticated_x_account, :string
  end
end
