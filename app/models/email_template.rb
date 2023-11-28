class EmailTemplate < ApplicationRecord
  def as_json(options = {})
    super(:except => [:created_at, :updated_at])
  end
end
