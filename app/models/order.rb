#TODO: translate attributes with i18n and active model translation?
class DeliveryMethodDetailsValidator < ActiveModel::Validator
  def validate(order)
    if order.is_delivery_method_send?
      if order.is_shipping_allowed?
        if order.is_univ?
          if order.delivery_box.blank?
            order.errors[:delivery_box] << "is required"
          end
        else
          if order.delivery_address.blank?
            order.errors[:delivery_address] << "is required"
          end
          if order.delivery_postal_code.blank?
            order.errors[:delivery_postal_code] << "is required"
          end
          if order.delivery_city.blank?
            order.errors[:delivery_city] << "is required"
          end
        end
      else
        order.errors[:delivery_method] << "\"send\" is not allowed for order that is not shippable"
      end
    elsif order.pickup_location.blank?
      order.errors[:pickup_location] << "is required"
    end
  end
end

class InvoicingDetailsValidator < ActiveModel::Validator
  def validate(order)
    if order.is_invoicing_required?
      if order.is_invoicing_by_id?
        if order.invoicing_id.blank?
          order.errors[:invoicing_id] << "is required"
        end
      else
        if order.invoicing_company.blank?
          order.errors[:invoicing_company] << "is required" # organisation/company
        end
        if order.invoicing_name.blank?
          order.errors[:invoicing_name] << "is required"
        end
        if order.invoicing_address.blank?
          order.errors[:invoicing_address] << "is required" #address/box
        end
        if order.invoicing_postal_address1.blank?
          order.errors[:invoicing_postal_address1] << "is required" #Invoicing postal code
        end
        if order.invoicing_postal_address2.blank?
          order.errors[:invoicing_postal_address2] << "is required" #Invoicing city
        end
      end
    end
  end
end

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
  belongs_to :customer_type

  # Shipping helpers
  def is_univ?
    customer_type.present? && customer_type.label == 'univ'
  end

  def is_delivery_method_send?
    delivery_method.present? && delivery_method.label == 'send'
  end

  def is_shippable?
    order_type.present? && !['loan', 'microfilm', 'score'].include?(order_type.label)
  end

  def is_shipping_allowed?
    is_shippable? && !['stud', 'priv'].include?(customer_type.label)
  end

  # Invoicing helpers
  def is_billable?
    order_type.present? && order_type.label != 'microfilm' && (order_type.label != 'book' || order_outside_scandinavia)
  end

  def is_invoicing_required? # is_invoicing_address_required? + is_invoicing_id_required? instead?
    customer_type.present? && is_billable? && ['sahl', 'ftag', 'ovri'].include?(customer_type.label)
  end

  def is_invoicing_by_id?
    customer_type.present? && customer_type.label == 'sahl'
  end

  validates :authenticated_x_account, presence: true, if: -> { order_type.present? && order_type.auth_required }

  # Relationship validations
  #validates :managing_group, presence: true #??
  validates :status, presence: true #??
  #validates :delivery_source, presence: true # Most likely not required
  validates :delivery_method, presence: true
  validates :order_type, presence: true
  validates :customer_type, presence: true
  validates :order_path, presence: true

  ## Per order type validations ##
  with_options if: -> { order_path.present? && order_path != 'SFX' && order_type.present? && order_type.label == 'loan' }, presence: true do |required|
    required.validates :title
    required.validates :authors
  end

  with_options if: -> { order_path.present? && order_path != 'SFX' && order_type.present? && order_type.label == 'photocopy' }, presence: true do |required|
    required.validates :journal_title
    required.validates :publication_year
    required.validates :pages
  end

  with_options if: -> { order_path.present? && order_path != 'SFX' && order_type.present? && order_type.label == 'photocopy_chapter' }, presence: true do |required|
    required.validates :title
    required.validates :journal_title
  end

  with_options if: -> { order_path.present? && order_path != 'SFX' && order_type.present? && order_type.label == 'microfilm' }, presence: true do |required|
    required.validates :title
    required.validates :period
  end

  with_options if: -> { order_path.present? && order_path != 'SFX' && order_type.present? && order_type.label == 'score' }, presence: true do |required|
    required.validates :title
    required.validates :authors
  end

  ##  Per customer type validations ##
  with_options if: -> { customer_type.present? && customer_type.label == 'univ' }, presence: true do |required|
    required.validates :name
    required.validates :email_address
    required.validates :company2
    required.validates :library_card_number
    required.validates :x_account
  end

  with_options if: -> { customer_type.present? && customer_type.label == 'stud' }, presence: true do |required|
    required.validates :name
    required.validates :email_address
    required.validates :library_card_number
    required.validates :x_account
  end

  with_options if: -> { customer_type.present? && customer_type.label == 'dist' }, presence: true do |required|
    required.validates :name
    required.validates :email_address
    required.validates :library_card_number
  end

  with_options if: -> { customer_type.present? && customer_type.label == 'sahl' }, presence: true do |required|
    required.validates :name
    required.validates :email_address
    required.validates :company3
  end

  with_options if: -> { customer_type.present? && customer_type.label == 'priv' }, presence: true do |required|
    required.validates :name
    required.validates :library_card_number
  end

  # Make sure correct:
  with_options if: -> { customer_type.present? && customer_type.label == 'ftag' || customer_type.label == 'ovri' }, presence: true do |required|
    required.validates :name
    required.validates :email_address
    required.validates :company1
  end

  with_options if: -> { customer_type.present? && customer_type.label == 'koha' }, presence: true do |required|
    required.validates :x_account
  end

  # Per delivery method validations
  validates_with DeliveryMethodDetailsValidator

  # Invoicing details validations
  validates_with InvoicingDetailsValidator

  #validates_format_of :email, with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i #??
  # TODO: when in to_be_invoiced used?

  # Box not in delivery uppgifter for foretag?

  # default number of entries per page
  self.per_page = Illbackend::Application.config.pagination[:orders_per_page] || 100

  def self.search(search_term)
    Order.where("(lower(name) LIKE ?)",
      "%#{search_term.downcase}%")
  end

  def sticky_note_subject
    Note.find_by_id(sticky_note_id).present? ? Note.find_by_id(sticky_note_id)[:subject] : nil
  end

  def sticky_note_message
    Note.find_by_id(sticky_note_id).present? ? Note.find_by_id(sticky_note_id)[:message] : nil
  end

  #def set_delivery_method
  #  if delivery_place.starts_with?('Hämtas')
  #    self.delivery_method = DeliveryMethod.find_by_label('pickup')
  #  elsif self.delivery_place.starts_with?('Skickas')
  #    self.delivery_method = DeliveryMethod.find_by_label('send')
  #  else
  #    self.delivery_method = DeliveryMethod.find_by_label('pickup')
  #  end
  #end

  def set_managing_group
    if order_type.present?
      case order_type.label
      when 'loan'
        self.managing_group = ManagingGroup.find_by_label('loan')
      when 'photocopy'
        self.managing_group = ManagingGroup.find_by_label('copies')
      when 'photocopy_chapter'
        self.managing_group = ManagingGroup.find_by_label('copies')
      when 'microfilm'
        self.managing_group = ManagingGroup.find_by_label('microfilm')
      when 'score'
        self.managing_group = ManagingGroup.find_by_label('score')
      else
        self.managing_group = ManagingGroup.find_by_label('loan')
      end
    end
  end

  def as_json(options = {})
    super(:methods => [:sticky_note_subject, :sticky_note_message])
  end
end
