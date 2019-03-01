class Order < ActiveRecord::Base
  auto_strip_attributes :libris_lf_number
  nilify_blanks

  has_many :notes
  belongs_to :user
  has_many :users, :through => :notes
  belongs_to :pickup_location
  belongs_to :status
  belongs_to :order_type
  belongs_to :delivery_source

   # default number of entries per page 
  self.per_page = Illbackend::Application.config.pagination[:orders_per_page] || 100

  def self.search(search_term)
    Order.where("(lower(name) LIKE ?)",
      "%#{search_term.downcase}%")
  end
  

  def sticky_note_subject
    Note.find_by_id(self.sticky_note_id).present? ? Note.find_by_id(self.sticky_note_id)[:subject] : nil
  end

  def sticky_note_message
    Note.find_by_id(self.sticky_note_id).present? ? Note.find_by_id(self.sticky_note_id)[:message] : nil
  end

  def as_json(options = {})
    super(:methods => [:sticky_note_subject, :sticky_note_message])
  end
end
