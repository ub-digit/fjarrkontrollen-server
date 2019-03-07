class CreateDeliveryMethods < ActiveRecord::Migration
  def change
    create_table :delivery_methods do |t|
      t.string :label
      t.string :name
      t.string :public_name_sv
      t.string :public_name_en
      
      t.timestamps
    end
  end
end
