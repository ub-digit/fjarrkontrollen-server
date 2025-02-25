class KohaPatronsController < ApplicationController
  before_action :validate_token

  def parse_patron(response_body)
    patron = {
      'denied' => false, # spärrad
      'warning' => false, # ska varnas
      'fines_amount' => nil, # bötesbelopp
      'restriction_fines' => false, # böter mer än 69 kr
      'restriction_av' => false, # avstängd
      'restriction_or' => false, # obetald räkning
      'restriction_ori' => false, # obetald räkning inkasso
      'restriction_overdue' => false # 2a krav
    };

    xml = Nokogiri::XML(response_body).remove_namespaces!
    {
      "categorycode" => "user_category",
      "membernumber" => "id",
      "surname" => "last_name",
      "firstname" => "first_name",
      "address" => "address",
      "address2" => "address2",
      "zipcode" => "zipcode",
      "city" => "city",
      "cardnumber" => "cardnumber",
      "borrowernumber" => "borrowernumber",
      "email" => "email",
      "phone" => "phone",
      "userid" => "xaccount"
    }.each do |xml_source, target|
      value = xml.search("//response/borrower/#{xml_source}")
      if value.text.present?
        patron[target] = value.text
      else
        patron[target] = nil
      end
    end

    xml.xpath('//response/debarments').each do |debarment|
      if debarment.xpath('comment').text.starts_with?('AV, ')
        patron['restriction_av'] = true
        patron['denied'] = true
      end
      if debarment.xpath('comment').text.starts_with?('OR, ')
        patron['restriction_or'] = true
        patron['warning'] = true
      end
      if debarment.xpath('comment').text.starts_with?('ORI, ')
        patron['restriction_ori'] = true
        patron['denied'] = true
      end
      if debarment.xpath('comment').text.starts_with?('OVERDUES_PROCESS ')
        patron['restriction_overdue'] = true
        patron['warning'] = true
      end
    end

    xml.xpath('//response/flags').each do |flag|
      if flag.xpath('name').text == 'CHARGES'
        if flag.xpath('amount').text.to_i > 69
          patron['restriction_fines'] = true
          patron['warning'] = true
        end
        patron['fines_amount'] = flag.xpath('amount').text
      end
    end

    if xml.search('//response/attributes[code="ORG"]/attribute').text.present?
      patron['organisation'] = xml.search('//response/attributes[code="ORG"]/attribute').text
    else
      patron['organisation'] = ""
    end

  patron
end

  def show
    permitted = params.require(:cardnumber)
    cardnumber = params[:cardnumber]

    base_url = APP_CONFIG['koha']['base_url']
    user = APP_CONFIG['koha']['user']
    password = APP_CONFIG['koha']['password']
    url = "#{base_url}/members/get?borrower=#{cardnumber}&login_userid=#{user}&login_password=#{password}"

    begin
      response = RestClient.get url
      patron = parse_patron response.body
      render json: {patron: patron}, status: 200
    rescue RestClient::NotFound => error
      render json: {}, status: 404
    rescue RestClient::ExceptionWithResponse => error
      logger.error "KohaPatronsController#show: Error requesting patron info"
      logger.error "#{error.message}"
      logger.error "#{url}"
      render json: {}, status: 500
    end
  end
end
