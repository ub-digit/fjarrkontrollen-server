class DeliveryMethod < ActiveRecord::Base
  has_many :orders

  validates_presence_of :label
  validates_uniqueness_of :label
  
  def as_json(options = {})
    super(:except => [:created_at, :updated_at])
  end
end
