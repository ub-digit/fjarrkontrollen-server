class AddColumnIsActiveToPickupLocations < ActiveRecord::Migration
  def change
    add_column :pickup_locations, :is_active, :boolean
  end
end
