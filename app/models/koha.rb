# encoding: utf-8
class Koha
  def self.create_bib_and_item order
    Rails.logger.info "Entering Koha#create_bib_and_item, order number: #{order[:order_number]}"

    # Use sigel and not label field to get a valid sigel
    order.pickup_location_id ? si = PickupLocation.find_by_id(order[:pickup_location_id])[:sigel] : si = ''
    order.authors ? au =  order.authors : au = ''
    order.title ? ti =  order.title : ti = ''
    order.publication_year ? yr =  order.publication_year : yr = ''
    order.issn_isbn ? isbn =  order.issn_isbn : isbn = ''
    order.lending_library ? ll =  order.lending_library : ll = ''
    order.order_number ? item =  order.order_number : item = ''

    if si.blank? || ti.blank? || ll.blank? || item.blank?
      missing_fields = []
      si.blank? ? missing_fields << "pickup_location_id" : ""
      ti.blank? ? missing_fields << "title" : ""
      ll.blank? ? missing_fields << "lending_library" : ""
      item.blank? ? missing_fields << "order_number" : ""
      Rails.logger.error "Leaving Koha#create_bib_and_item, error, missing fields: #{missing_fields.join(", ")}"
      return false
    end

    mt = "a" #monograph
    mt = "c" if order.order_type_id && OrderType.find_by_id(order.order_type_id).label.eql?("score")

    userid = Illbackend::Application.config.koha[:userid]
    password = Illbackend::Application.config.koha[:password]
    params = {userid: userid, password: password, si: si, au: au, ti: ti, yr: yr, isbn: isbn, ll: ll, mt: mt, item: item}
    response = RestClient.get Illbackend::Application.config.koha[:create_bib_and_item_url], :params => params

    if response.code != 200
      Rails.logger.error "Leaving Koha#create_bib_and_item, error: response code from Koha: #{response.code}"
      return false
    end
    if !response.body.include?("biblionumber")
      Rails.logger.error "Leaving Koha#create_bib_and_item, error: response body from Koha: #{response.body}"
      return false
    end
    Rails.logger.info "Leaving Koha#create_bib_and_item, success"
    return true

  rescue RestClient::ResourceNotFound, RestClient::BadRequest, URI::InvalidURIError => e
    Rails.logger.error "Leaving Koha#create_bib_and_item, exception: #{e}"
    return false
  end

  def self.delete_bib_and_item order_number
    Rails.logger.info "Entering Koha#delete_bib_and_item, order number: #{order_number}"

    userid = Illbackend::Application.config.koha[:userid]
    password = Illbackend::Application.config.koha[:password]
    params = {userid: userid, password: password, item: order_number}
    response = RestClient.get Illbackend::Application.config.koha[:delete_bib_and_item_url], :params => params

    if response.code != 200
      Rails.logger.error "Leaving Koha#delete_bib_and_item, error: response code from Koha: #{response.code}"
      return false
    end
    if !response.body.include?("success")
      Rails.logger.error "Leaving Koha#delete_bib_and_item, error: response body from Koha: #{response.body}"
      return false
    end
    Rails.logger.info "Leaving Koha#delete_bib_and_item, success"
    return true

  rescue RestClient::ResourceNotFound, RestClient::BadRequest, URI::InvalidURIError => e
    Rails.logger.error "Leaving Koha#delete_bib_and_item, exception: #{e}"
    return false
  end
end
