class CreateCustomerTypes < ActiveRecord::Migration
  def change
    create_table :customer_types do |t|
      t.string :label
      t.string :name_sv
      t.string :name_en

      t.timestamps null: false
    end
  end
end
