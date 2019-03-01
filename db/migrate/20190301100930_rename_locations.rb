class RenameLocations < ActiveRecord::Migration
  def change
  	rename_table :locations, :pickup_locations
  end
end
