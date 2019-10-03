class CreateNoteTypes < ActiveRecord::Migration
  def change
    create_table :note_types do |t|
      t.string :label
      
      t.timestamps
    end
  end
end
