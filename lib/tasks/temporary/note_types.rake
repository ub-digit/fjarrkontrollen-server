namespace :note_types do
  desc "Create note types"
  task create: :environment do
    puts "Creating note types"

    ActiveRecord::Base.transaction do
      load(Rails.root.join('db', 'seeds', 'note_types.rb'))
    end

    puts " All done!"
  end

  desc "Migrate note types data"
  task migrate_data: :environment do
    puts "Migrating note types data"

    Note.all.each do |note|
      if note.is_email == TRUE
        note.note_type_id = NoteType.find_by_label('email').id
      elsif / ändrades från /i =~ note.message
        note.note_type_id = NoteType.find_by_label('system').id
      elsif / ändrades./ =~ note.message
        note.note_type_id = NoteType.find_by_label('system').id
      elsif /Beställning uppdaterad./ =~ note.message
        note.note_type_id = NoteType.find_by_label('system').id
      elsif /Beställningen arkiverades./ =~ note.message
        note.note_type_id = NoteType.find_by_label('system').id
      elsif /Beställningen avarkiverades./ =~ note.message
        note.note_type_id = NoteType.find_by_label('system').id
      else
        note.note_type_id = NoteType.find_by_label('user').id
      end
      note.save!
    end    
    puts " All done!"
  end
end

