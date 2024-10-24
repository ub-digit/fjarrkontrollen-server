class Status < ApplicationRecord
  has_many :orders
  has_many :status_group_members
  has_many :statuses, :through => :status_group_members

  validates_presence_of :label
  validates_uniqueness_of :label
  
  def as_json(options = {})
    super(:except => [:created_at, :updated_at])
  end
end
