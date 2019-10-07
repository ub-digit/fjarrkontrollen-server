class AddNoteTypeIdToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :note_type_id, :integer
  end
end
