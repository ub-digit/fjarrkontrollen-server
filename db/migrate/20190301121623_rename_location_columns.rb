class RenameLocationColumns < ActiveRecord::Migration
  def change
    rename_column :orders, :location_id, :pickup_location_id  	
    rename_column :users, :location_id, :pickup_location_id  	
  end
end
