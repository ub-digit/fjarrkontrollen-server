# encoding: utf-8
class Koha
  def self.create_bib_and_item order
    Rails.logger.info "Entering Koha#create_bib_and_item, order number: #{order[:order_number]}"

    # Use sigel and not label field to get a valid sigel
    sublocation = ManagingGroup.find_by_id(order.managing_group_id).sublocation
    if sublocation.blank?
      Rails.logger.error "Leaving Koha#create_bib_and_item, error, no sublocation for managing group}"
      return {biblio_item: false, reserve: nil}
    end

    branch = sublocation[0,2]
    location = sublocation

    pickup_location = order.pickup_location.code

    au = order.authors ? order.authors : ''
    ti = order.title ? order.title : ''
    yr = order.publication_year ? order.publication_year : ''
    isbn = order.issn_isbn ? order.issn_isbn : ''
    ll = order.lending_library ? order.lending_library : ''
    item = order.order_number ? order.order_number : ''
    borrowernumber = order.koha_borrowernumber ? order.koha_borrowernumber : ''

    if ti.blank? || item.blank?
      missing_fields = []
      ti.blank? ? missing_fields << "title" : ""
      item.blank? ? missing_fields << "order_number" : ""
      Rails.logger.error "Leaving Koha#create_bib_and_item, error, missing fields: #{missing_fields.join(", ")}"
      return {biblio_item: false, reserve: nil}
    end

    mt = "a" #monograph
    mt = "c" if order.order_type_id && OrderType.find_by_id(order.order_type_id).label.eql?("score")

    userid = Illbackend::Application.config.koha[:userid]
    password = Illbackend::Application.config.koha[:password]
    params = {userid: userid, password: password, branch: branch, location: location, au: au, ti: ti, yr: yr, isbn: isbn, ll: ll, mt: mt, item: item, borrowernumber: borrowernumber, pickup_location: pickup_location}
    response = RestClient.get Illbackend::Application.config.koha[:create_bib_and_item_url], :params => params

    if response.code != 200
      Rails.logger.error "Leaving Koha#create_bib_and_item, error: response code from Koha: #{response.code}"
      return {biblio_item: false, reserve: nil}
    end
    if !response.body.include?("biblionumber")
      Rails.logger.error "Leaving Koha#create_bib_and_item, error: response body from Koha: #{response.body}"
      return {biblio_item: false, reserve: nil}
    end

    if response.body.include?("<reserve_status>no_borrower_supplied</reserve_status>")
      Rails.logger.info "Leaving Koha#create_bib_and_item, success, nno borrower supplied"
      return {biblio_item: true, reserve: "no_borrower_supplied"}
    end

    if response.body.include?("<reserve_status>no_borrower_found</reserve_status>")
      Rails.logger.info "Leaving Koha#create_bib_and_item, success,no borrower found"
      return {biblio_item: true, reserve: "no_borrower_found"}
    end

    if response.body.include?("<reserve_status>error</reserve_status>") 
      Rails.logger.info "Leaving Koha#create_bib_and_item, success, reserve error"
      return {biblio_item: true, reserve: "error"}
    end

    Rails.logger.info "Leaving Koha#create_bib_and_item, success, reserve success"
    return {biblio_item: true, reserve: "success"}

  rescue RestClient::ResourceNotFound, RestClient::BadRequest, URI::InvalidURIError => e
    Rails.logger.error "Leaving Koha#create_bib_and_item, exception: #{e}"
    return {biblio_item: false, reserve: nil}
  end

  def self.update_bib_and_item order
    Rails.logger.info "Entering Koha#update_bib_and_item, order number: #{order[:order_number]}"

    # Use sigel and not label field to get a valid sigel
    sublocation = ManagingGroup.find_by_id(order.managing_group_id).sublocation
    if sublocation.blank?
      Rails.logger.error "Leaving Koha#update_bib_and_item, error, no sublocation for managing group}"
      return false
    end

    branch = sublocation[0,2]
    location = sublocation

    au = order.authors ? order.authors : ''
    ti = order.title ? order.title : ''
    yr = order.publication_year ? order.publication_year : ''
    isbn = order.issn_isbn ? order.issn_isbn : ''
    ll = order.lending_library ? order.lending_library : ''
    item = order.order_number ? order.order_number : ''

    if ti.blank? || ll.blank? || item.blank?
      missing_fields = []
      ti.blank? ? missing_fields << "title" : ""
      ll.blank? ? missing_fields << "lending_library" : ""
      item.blank? ? missing_fields << "order_number" : ""
      Rails.logger.error "Leaving Koha#update_bib_and_item, error, missing fields: #{missing_fields.join(", ")}"
      return false
    end

    mt = "a" #monograph
    mt = "c" if order.order_type_id && OrderType.find_by_id(order.order_type_id).label.eql?("score")

    userid = Illbackend::Application.config.koha[:userid]
    password = Illbackend::Application.config.koha[:password]
    params = {userid: userid, password: password, branch: branch, location: location, au: au, ti: ti, yr: yr, isbn: isbn, ll: ll, mt: mt, item: item}
    response = RestClient.get Illbackend::Application.config.koha[:update_bib_and_item_url], :params => params

    if response.code != 200
      Rails.logger.error "Leaving Koha#update_bib_and_item, error: response code from Koha: #{response.code}"
      return false
    end
    if !response.body.include?("biblionumber")
      Rails.logger.error "Leaving Koha#update_bib_and_item, error: response body from Koha: #{response.body}"
      return false
    end
    Rails.logger.info "Leaving Koha#update_bib_and_item, success"
    return true

  rescue RestClient::ResourceNotFound, RestClient::BadRequest, URI::InvalidURIError => e
    Rails.logger.error "Leaving Koha#update_bib_and_item, exception: #{e}"
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
