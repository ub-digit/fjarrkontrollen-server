class CreateBatchImports < ActiveRecord::Migration[7.1]
  def change
    create_table :batch_imports do |t|
      t.integer :batch_id
      t.integer :order_id
      t.string :request_id
      t.string :article_title
      t.string :journal_title
      t.string :issn
      t.string :publication_year
      t.string :volume
      t.string :pages
      t.string :issue
      t.text :authors
      t.string :item_identifier
      t.string :item_identifier_source
      t.text :error
      t.datetime :imported_at
      t.boolean :processed, default: false
      t.timestamps
    end

    add_index :batch_imports, :batch_id
    add_index :batch_imports, :request_id

    execute <<-SQL
      CREATE SEQUENCE batch_imports_batch_id_seq START 1;
    SQL
  end
end
