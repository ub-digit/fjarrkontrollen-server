class AddPositionToOrderTypes < ActiveRecord::Migration[7.1]
  def change
    add_column :order_types, :position, :integer
  end
end
