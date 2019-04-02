class RenameObsoleteCustomerTypeField < ActiveRecord::Migration
  def change
    rename_column :orders, :customer_type, :customer_type_old
  end
end
