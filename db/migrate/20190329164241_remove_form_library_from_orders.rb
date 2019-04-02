class RemoveFormLibraryFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :form_library, :string
  end
end
