class StatusGroupMember < ActiveRecord::Base
  belongs_to :status
  belongs_to :status_group

  validates :status_id, uniqueness: { scope: :status_group_id, message: "should exist once per status group" }
end
