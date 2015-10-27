class Order < ActiveRecord::Base
  #attr_accessor :id, :order_id, :order_type, :title, :publication_year, :volume, :issue, :pages, :journal_title, :issn_isbn, :reference_information, :photocopies_if_loan_not_possible, :order_outside_scandinavia, :email_confirmation, :not_valid_after, :delivery_type, :name, :company1, :company2, :company3, :phone_number, :email_address, :library_card_number, :customer_type, :comments, :form_lang, :authors, :form_library, :delivery_place, :location, :invoicing_name, :invoicing_address, :invoicing_postal_address1, :invoicing_postal_address2, :order_path, :status_id, :user_id, :sticky_note_id
  #attr_reader :id
  auto_strip_attributes :libris_lf_number
  nilify_blanks

  has_many :notes
  belongs_to :user
  has_many :users, :through => :notes
  belongs_to :location
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
