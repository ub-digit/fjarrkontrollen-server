class OrderTypeDetailsValidator < ActiveModel::Validator
  def validate(order)
    case order.order_type.label
    when "loan"
      if order.title.blank?
        order.errors[:title] << "Title is required"
      end
      if order.authors.blank?
        order.errors[:authors] << "Author/publisher is required"
      end
    when "photocopy"
      if order.title.blank?
        order.errors[:title] << "Journal title is required"
      end
      if order.publication_year.blank?
        order.errors[:publication_year] << "Year is required"
      end
      if order.pages.blank?
        order.errors[:pages] << "Pages is required"
      end
    when "photocopy_chapter"
      if order.title.blank?
        order.errors[:title] << "Chapter title is required"
      end
      if order.title.blank?
        order.errors[:journal_title] << "Book title is required"
      end
    when "microfilm"
      if order.title.blank?
        order.errors[:title] << "Newspaper is required"
      end
      if order.period.blank?
        order.errors[:period] << "Date/period is required"
      end
    when "score"
      if order.title.blank?
        order.errors[:authors] << "Composer is required"
      end
      if order.period.blank?
        order.errors[:title] << "Title is required"
      end
    end
  end
end

class DeliveryMethodDetailsValidator < ActiveModel::Validator
  def validate(order)
    if order.is_delivery_method_send?
      if order.is_shipping_allowed?
        if order.delivery_address.blank?
          order.errors[:delivery_address] << "is required"
        end
        if order.delivery_postal_code.blank?
          order.errors[:delivery_postal_code] << "is required"
        end
        if order.delivery_city.blank?
          order.errors[:delivery_city] << "is required"
        end
      else
        order.errors[:delivery_method] << "\"send\" is not allowed for order that is not shippable"
      end
    elsif order.pickup_location.empty?
      order.errors[:pickup_location] << "is required"
    end
  end
end

class InvoicingDetailsValidator < ActiveModel::Validator
  def validate(order)
    if order.is_invoicing_required?
      if order.customer_type.label == 'sahl'
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

class CustomerTypeDetailsValidator < ActiveModel::Validator
  #TODO: Also validade relationship presence here, and same for other validators?

  def validate(order)
    def validate_properties(properties)
      properties.each do |property|
        case property
        when "name"
          if order.name.blank?
            order.errors[:name] << "Name is required"
          end
        when "email_address"
          if order.email_address.blank?
            order.errors[:email_address] << "E-mail is required"
          end
        when "company1"
          if order.company1.blank?
            order.errors[:company1] << "Organisation/company is required"
          end
        when "company2"
          if order.company2.blank?
            order.errors[:company2] << "Department is required"
          end
        when "company3"
          if order.company3.blank?
            order.errors[:company3] << "Unit is required"
          end
        when "library_card_number"
          if order.library_card_number.blank?
            order.errors[:library_card_number] << "Library card number is required" #
          end
        when "x_account"
          if order.x_account.blank?
            order.errors[:x_account] << "x-account is required" #x uppercase?
          end
        end
      end
    end
    case order.customer_type.label
    when "univ"
      validate_properties([
        "name",
        "email_address",
        "company2",
        "library_card_number",
        "x_account"
      ])
    when"stud"
      validate_properties([
        "name",
        "email_address",
        "library_card_number"
      ])
    when"sahl"
      validate_properties([
        "name",
        "email_address",
        "company3"
      ])
    when "priv"
      validate_properties([
        "name",
        "library_card_number"
      ])
    when "ftag"
      validate_properties([
        "company1",
        "name",
        "email_address"
      ])
    when "dist"
      validate_properties([
        "name",
        "email_address",
        "library_card_number"
      ])
    when "ovri"
      validate_properties([
        "company1",
        "name",
        "email_address"
      ])
    when "koha"
      # TODO: Require more??? Should request from koha and fill in all available properties
      # overwrite from request or merge?
      validate_properties([
        "x_account"
      ])
    when "unknown"
      # Skip validations
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
  def is_delivery_method_send?
    # self?
    self.delivery_method.label == 'send'
  end

  def is_shippable?
    !['loan', 'microfilm', 'score'].include?(self.order_type.label)
  end

  def is_shipping_allowed?
    is_shippable? && !['stud', 'priv'].include?(self.order_type.label)
  end

  # Invoicing helpers
  def is_billable?
    self.order_type.label != 'microfilm' && (self.order_type.label != 'book' || self.order_outside_scandinavia)
  end

  def is_invoicing_required? # is_invoicing_address_required? + is_invoicing_id_required? instead?
    is_billable? && ['sahl', 'ftag', 'ovri'].include?(self.customer_type.label)
  end

  # Relationship validations
  #validates :managing_group, presence: true #??
  validates :status, presence: true #??
  validates :order_type, presence: true
  #validates :delivery_source, presence: true # Most likely not required
  validates :delivery_method, presence: true

  # Property validations

  # Per order type validations
  validates_with OrderTypeDetailsValidator

  # Per delivery method validations
  validates_with DeliveryMethodDetailsValidator

  # Invoicing details validations
  validates_with InvoicingDetailsValidator

  # Per customer type validataions
  validates_with CustomerTypeDetailsValidator

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
