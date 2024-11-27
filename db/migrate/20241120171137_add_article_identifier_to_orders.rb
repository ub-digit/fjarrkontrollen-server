class AddArticleIdentifierToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :article_identifier, :string
    add_column :orders, :article_identifier_source, :string
  end
end
