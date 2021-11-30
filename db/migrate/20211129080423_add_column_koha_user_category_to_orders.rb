class AddColumnKohaUserCategoryToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :koha_user_category, :string    
  end
end
