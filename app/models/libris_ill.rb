class LibrisILL

  # Takes a Libris LF Number and returns an order in Libris fjärrlån
  def self.get_order lf_number
    response = RestClient.get Illbackend::Application.config.librisill_settings[:base_url] + "illrequests/G/" + lf_number
    if response.code == 200 
      json_response = JSON.parse(response)
  	  return json_response["ill_requests"][0]
    else 
    	return {}
    end
  end

  
  # Takes a Libris LF Number an returns true if the order status is 6 (Negativt svar), false otherwise.
  def self.negative_response? lf_number
    Rails.logger.info "Entering LibrisILL#negative_response?, lf_number: #{lf_number}"
    begin
      response = RestClient.get Illbackend::Application.config.librisill_settings[:base_url] + "illrequests/G/" + lf_number     
      if response.code == 200 
        json_response = JSON.parse(response)
  	    if json_response["count"].to_i > 0 
          Rails.logger.info "Leaving LibrisILL#negative_response?, lf_number found"
          return json_response["ill_requests"][0]["status_code"].eql?("6")  
        end
      end
    rescue RestClient::ResourceNotFound, URI::InvalidURIError => e
      Rails.logger.error "Leaving LibrisILL#negative_response?, exception: #{e}"
      return false
    end
    Rails.logger.info "Leaving LibrisILL#negative_response?, lf_number not found"
    return false
  end

  def self.get_user_requests library_code
    response = RestClient.get Illbackend::Application.config.librisill_settings[:base_url] + "userrequests/" + library_code
    if response.code == 200 
      json_response = JSON.parse(response)
      return json_response
    else 
      return {}
    end
  end  


end