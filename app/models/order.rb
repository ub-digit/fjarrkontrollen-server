class Order < ActiveRecord::Base
  auto_strip_attributes :libris_lf_number
  nilify_blanks

  has_many :notes
  belongs_to :user
  has_many :users, :through => :notes
  belongs_to :pickup_location
  belongs_to :managing_group
  belongs_to :status
  belongs_to :order_type
  belongs_to :delivery_source
  belongs_to :delivery_method

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

  def set_delivery_method
    if self.delivery_place.starts_with?("Hämtas")
      self.delivery_method_id = DeliveryMethod.find_by_label("pickup").id
    elsif self.delivery_place.starts_with?("Skickas")
      self.delivery_method_id = DeliveryMethod.find_by_label("send").id
    else
      self.delivery_method_id = DeliveryMethod.find_by_label("pickup").id
    end
  end

  def set_managing_group
    case self.order_type_id
    when OrderType.find_by_label("loan").id
      self.managing_group_id = ManagingGroup.find_by_label("loan").id
    when OrderType.find_by_label("photocopy").id
      self.managing_group_id = ManagingGroup.find_by_label("copies").id
    when OrderType.find_by_label("photocopy_chapter").id
      self.managing_group_id = ManagingGroup.find_by_label("copies").id
    when OrderType.find_by_label("microfilm").id
      self.managing_group_id = ManagingGroup.find_by_label("microfilm").id
    when OrderType.find_by_label("score").id
      self.managing_group_id = ManagingGroup.find_by_label("score").id
    else
      self.managing_group_id = ManagingGroup.find_by_label("loan").id
    end
  end

  def as_json(options = {})
    super(:methods => [:sticky_note_subject, :sticky_note_message])
  end
end
