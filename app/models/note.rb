class Note < ActiveRecord::Base
  belongs_to :order
  belongs_to :user
  belongs_to :note_type
end
