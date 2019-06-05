class AddColumnIsAvailableToPickupLocation < ActiveRecord::Migration
  def change
    add_column :pickup_locations, :is_available, :boolean, default: true
  end
end
