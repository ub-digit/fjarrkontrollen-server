class AddBranchCodeToPickupLocation < ActiveRecord::Migration
  def change
  	add_column :pickup_locations, :code, :string  	
  end
end
