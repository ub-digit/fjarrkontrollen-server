class AddArticleIdentifierToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :article_identifer, :string    
    add_column :orders, :article_identifer_source, :string    
  end
end
