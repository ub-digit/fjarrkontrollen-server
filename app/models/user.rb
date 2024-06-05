
class User < ApplicationRecord
   include ActiveModel::Validations
DEFAULT_TOKEN_EXPIRE = 1.day
# superfluous comment
  has_many :orders
  has_many :notes
  has_many :orders, :through => :notes
  belongs_to :managing_group
  belongs_to :pickup_location
  has_many :access_tokens


  validates :xkonto, :name, presence: true
  validates_uniqueness_of :xkonto 

  def authenticate(provided_password)
    uri = URI('https://login-server.ub.gu.se/auth/' + xkonto)
    params = { :password => provided_password}
    params[:service] = 'test' if Rails.env == 'test'
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)
    json_response = JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
    #puts json_response["auth"]["yesno"]

    if(json_response["auth"]["yesno"])
      token_object = generate_token
      return token_object.token
    end
    false
  end

  def generate_token
    access_tokens.create(token: SecureRandom.hex, token_expire: Time.now + DEFAULT_TOKEN_EXPIRE)
  end

  def clear_expired_tokens
    access_tokens.where("token_expire < ?", Time.now).destroy_all
  end

  def validate_token(provided_token)
    clear_expired_tokens
    token_object = access_tokens.find_by_token(provided_token)
    return false if !token_object
    token_object.update_attribute(:token_expire, Time.now + DEFAULT_TOKEN_EXPIRE)
    true
  end

  def as_json(options = {})
    {
      id: id,
      xkonto: xkonto,
      managing_group_id: managing_group_id,
      pickup_location_id: pickup_location_id,
      name: name
    }
  end


end
