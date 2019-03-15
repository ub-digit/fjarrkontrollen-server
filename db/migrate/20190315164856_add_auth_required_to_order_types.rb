class AddAuthRequiredToOrderTypes < ActiveRecord::Migration
  def change
    add_column :order_types, :auth_required, :boolean, default: true, null: false
  end
end
