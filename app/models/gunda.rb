# encoding: utf-8
class Gunda

  CREATE_SUCCESS_STR = 'Skickat till GUNDA för laddning'
  DELETE_SUCCESS_STR_1 = 'Borttagningen av exposten lyckades'
  DELETE_SUCCESS_STR_2 = 'Borttagningen av bibposten lyckades'

  def self.create_bib_and_item order
    Rails.logger.info "Entering Gunda#create_bib_and_item, order number: #{order[:order_number]}"

  	# Use sigel and not label field to get a valid sigel
    order[:location_id].present? ? si = Location.find_by_id(order[:location_id])[:sigel] : si = ''
    order[:authors].present? ? au =  order[:authors] : au = ''
    order[:title].present? ? ti =  order[:title] : ti = ''
    order[:publication_year].present? ? yr =  order[:publication_year] : yr = ''
    order[:issn_isbn].present? ? isbn =  order[:issn_isbn] : isbn = ''
    order[:lending_library].present? ? ll =  order[:lending_library] : ll = ''
    order[:order_number].present? ? item =  order[:order_number] : item = ''

    # Following fields are mandatory when creating an item in Gunda:
    #location_id
    #title
    #publication_year
    #lending_library
    #order_number

    if si.blank? || ti.blank? || yr.blank? || ll.blank? || item.blank?
      missing_fields = []
      si.blank? ? missing_fields << "location_id" : ""
      ti.blank? ? missing_fields << "title" : ""
      yr.blank? ? missing_fields << "publication_year" : ""
      ll.blank? ? missing_fields << "lending_library" : ""
      item.blank? ? missing_fields << "order_number" : ""
      Rails.logger.error "Leaving Gunda#create_bib_and_item, error, missing fields: #{missing_fields.join(", ")}"
      return false
    end

    if si.present?
      response = RestClient.get Illbackend::Application.config.gunda[:create_bib_and_item_url], :params => {si: si, au: au, ti: ti, yr: yr, isbn: isbn, ll: ll, item: item}
    else
      Rails.logger.error "Leaving Gunda#create_bib_and_item, error: missing sigel"
      return false
    end

    if response.code != 200
      Rails.logger.error "Leaving Gunda#create_bib_and_item, error: response code from Gunda: #{response.code}"
      return false
    end
    if !force_utf8(response.body).include?(CREATE_SUCCESS_STR)
      Rails.logger.error "Leaving Gunda#create_bib_and_item, error: response body from Gunda: #{response.body}"
      return false
    end
    Rails.logger.info "Leaving Gunda#create_bib_and_item, success"
    return true

  rescue RestClient::ResourceNotFound, URI::InvalidURIError => e
    Rails.logger.error "Leaving Gunda#create_bib_and_item, exception: #{e}"
    return false
  end



  def self.delete_bib_and_item order_number
    Rails.logger.info "Entering Gunda#delete_bib_and_item, order number: #{order_number}"

    response = RestClient.get Illbackend::Application.config.gunda[:delete_bib_and_item_url], :params => {item: order_number}

    if response.code != 200
      Rails.logger.error "Leaving Gunda#delete_bib_and_item, error: response code from Gunda: #{response.code}"
      return false
    end
    if !force_utf8(response.body).include?(DELETE_SUCCESS_STR_1) && !force_utf8(response.body).include?(DELETE_SUCCESS_STR_2)
      Rails.logger.error "Leaving Gunda#delete_bib_and_item, error: response body from Gunda: #{response.body}"
      return false
    end
    Rails.logger.info "Leaving Gunda#delete_bib_and_item, success"
    return true

  rescue RestClient::ResourceNotFound, URI::InvalidURIError => e
    Rails.logger.error "Leaving Gunda#delete_bib_and_item, exception: #{e}"
    return false
  end

  def self.item_exists? order_number
    Rails.logger.info "Entering Gunda#item_exists, order number: #{order_number}"

    response = RestClient.get Illbackend::Application.config.gunda[:find_item_by_barcode], :params => {barcode: order_number}
#    puts response.code
#    puts response.headers
#    puts response.body

    # TBD

    Rails.logger.info "Leaving Gunda#item_exists, not implemented"
    return false
  rescue RestClient::ResourceNotFound, URI::InvalidURIError => e
    Rails.logger.error "Leaving Gunda#item_exists, exception: #{e}"
    return false
  end



private
  def self.force_utf8 str
    if !str.force_encoding("UTF-8").valid_encoding?
      str = str.force_encoding("ISO-8859-1").encode("UTF-8")
    end
    return str
  end


end
