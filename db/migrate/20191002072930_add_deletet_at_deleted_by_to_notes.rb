class AddDeletetAtDeletedByToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :deleted_at, :datetime
    add_column :notes, :deleted_by, :string
  end
end
