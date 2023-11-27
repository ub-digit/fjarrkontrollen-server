class NoteType < ApplicationRecord
  has_many :notes

  validates_presence_of :label
  
  def as_json(options = {})
    super(:except => [:created_at, :updated_at])
  end
end
