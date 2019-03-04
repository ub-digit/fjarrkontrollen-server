class AddTableManagingGroups < ActiveRecord::Migration
  def change
    create_table :managing_groups do |t|
      t.string :label
      t.string :name
      t.string :email
      t.string :sublocation
      t.boolean :is_active
 
      t.timestamps
    end  	
  end
end
