require 'pp'
class BatchImport < ApplicationRecord
  def as_json(options = {})
    {
      request_id: self.request_id,
      db_id: self.id,
      display_title: as_vancouver,
      selected: options[:selected] || false,
      success: options[:success] || false,
    }
  end

  # String in vancouver style from database id
  def as_vancouver
    if self.error.present?
      return "Error: #{self.error}"
    end
    "#{self.authors}. #{self.article_title}. #{self.journal_title}. #{self.publication_year};#{self.volume}(#{self.issue}):#{self.pages}."
  rescue => e
    Rails.logger.error "Error generating Vancouver citation for BatchImport id #{self.id}: #{e.message}"
    "Error generating citation"
  end

  def self.validate_params(data)
    # Only customer_type_id needs to actually be verified to exist.
    errors = []
    if data[:customer_type_id].nil? || data[:customer_type_id].blank? || data[:customer_type_id].to_i == 0
      errors << {field: "customer_type_id", code: "missing", msg: "Missing customer_type_id"}
    else
      if !CustomerType.exists?(id: data[:customer_type_id].to_i)
        errors << {field: "customer_type_id", code: "invalid", msg: "customer_type_id not valid"}
      end
    end

    # Return errors or empty array if all good.
    return errors
  end

  # Create one order from the given item and provided metadata.
  def self.create_order_from_item(batch_id, item, metadata, current_user)
    batch_item = fetch_item(batch_id, item[:db_id], item[:request_id])
    if batch_item.nil?
      raise "Batch item not found or already processed for batch_id #{batch_id}, item_id #{item[:db_id]}, request_id #{item[:request_id]}"
    end
    if batch_item.error.present?
      raise "Cannot create order from item with error: #{batch_item.error}"
    end

    # Fetch order_type_id for order_type with label "photocopy"
    order_type = OrderType.find_by(label: "photocopy")
    customer_type = CustomerType.find_by(id: metadata[:customer_type_id])
    status = Status.find_by(label: "new")
    managing_group = ManagingGroup.find_by(label: "copies")

    # Create order
    order_data = {
      title: batch_item.article_title,
      journal_title: batch_item.journal_title,
      issn_isbn: batch_item.issn,
      publication_year: batch_item.publication_year,
      volume: batch_item.volume,
      pages: batch_item.pages,
      issue: batch_item.issue,
      authors: batch_item.authors,
      article_identifier: batch_item.item_identifier,
      article_identifier_source: batch_item.item_identifier_source,
      order_type_id: order_type.id,
      customer_type_id: metadata[:customer_type_id].to_i,
      pickup_location_id: metadata[:pickup_location_id].to_i,
      status_id: status.id,
      order_outside_scandinavia: false,
      is_archived: false,
      to_be_invoiced: false,
      managing_group_id: managing_group.id,
      delivery_method_id: metadata[:delivery_method_id].to_i,
      order_path: "Staff",
      authenticated_x_account: metadata[:authenticated_x_account],
      name: metadata[:name],
      email_address: metadata[:email_address],
      company1: metadata[:company1],
      company2: metadata[:company2],
      company3: metadata[:company3],
      x_account: metadata[:x_account],
      library_card_number: metadata[:library_card_number],
      koha_borrowernumber: metadata[:koha_borrowernumber],
      koha_user_category: metadata[:koha_user_category],
      delivery_address: metadata[:delivery_address],
      delivery_box: metadata[:delivery_box],
      delivery_postal_code: metadata[:delivery_postal_code],
      delivery_city: metadata[:delivery_city],
      comments: metadata[:comments],
      invoicing_name: metadata[:invoicing_name],
      invoicing_address: metadata[:invoicing_address],
      invoicing_postal_address1: metadata[:invoicing_postal_address1],
      invoicing_postal_address2: metadata[:invoicing_postal_address2],
      invoicing_id: metadata[:invoicing_id]
    }

    new_order = Order.new(order_data)
    new_order.save!(validate: false)
    created_at = new_order[:created_at]
    order_number = created_at.strftime("%Y%m%d%H%M%S") + new_order.id.to_s
    new_order.update_attribute(:order_number, order_number)

    # Add note about creation
    msg = "Ny order skapad.\nStatus satt till #{new_order.status.name_sv}."
    Note.create({user_id: current_user ? current_user.id : nil, order_id: new_order.id, message: msg, is_email: false, note_type_id: NoteType.find_by_label('system').id})

    # Mark batch item as processed and set imported_at to now.
    batch_item.update(processed: true, imported_at: Time.now, order_id: new_order.id)
    return new_order
  end

  # Fetch the item in the database with item_id and has batch_id and request_id matching the provided ones.
  # It must exist, and it cannot be processed yet.
  def self.fetch_item(batch_id, item_id, request_id)
    item = BatchImport.find_by(id: item_id, batch_id: batch_id, request_id: request_id, processed: false)
    return item
  end

  # Batch id is a separate sequence "batch_imports_batch_id_seq"
  def self.fetch_batch_id
    result = ActiveRecord::Base.connection.execute("SELECT nextval('batch_imports_batch_id_seq') AS batch_id")
    return result[0]['batch_id']
  end

  # Loop through all request ids. If it contains a "/" it is assumed to be a scopus id, otherwise pubmed.
  def self.fetch_batch(batch_id, request_ids_string)
    results = []
    # Split by newlines, strip whitespace of each, ignore empty lines
    request_ids = request_ids_string.to_s.split("\n").map(&:strip)
    request_ids.each do |id|
      id = id.to_s.strip
      next if id.blank?
      next if id == "0"
      if is_doi?(id)
        result = fetch_scopus(batch_id, id)
        results << BatchImport.new(result)
      else
        result = fetch_pubmed(batch_id, id)
        results << BatchImport.new(result)
      end
    end
    BatchImport.transaction do
      results.each(&:save!)
    end
    # Import results include all even those with errors.
    import_results = results

    # Failed imports are ONLY the request_id of those with errors.
    failed_imports = results.select { |r| r.error.present? }.map { |r| r.request_id }
    return { 
      "import_results" => import_results.map { |r| r.as_json(selected: r.error.blank?, success: r.error.blank?) },
      "failed_imports" => failed_imports
    }
  end

  def self.is_doi?(id)
    id.include?("/")
  end

  # Fetch pubmed/scopus tries to fetch, does parsing into db format, and returns a db ready hash.
  # If there is an error, it returns a hash with an error string in it.
  def self.fetch_pubmed(batch_id, id)
    encoded_id = URI.encode_www_form_component(id)
    url = APP_CONFIG['forms_backend_url'] + "/api/pubmed/" + encoded_id
    response = Net::HTTP.get_response(URI(url))
    status_code = response.code.to_i
    if status_code == 200
      begin
        json_response = JSON.parse(response.body)
        db_ready = pubmed_to_db(batch_id, id, json_response)
        if db_ready.nil?
          return error_object(batch_id, id, "No valid article found in Pubmed response")
        end
        return db_ready
      rescue JSON::ParserError
        return error_object(batch_id, id, "Invalid JSON response from Pubmed")
      rescue => e
        return error_object(batch_id, id, "Error processing Pubmed data: #{e.message}")
      end
    else
      return error_object(batch_id, id, "Failed to fetch from Pubmed, status code: #{status_code}")
    end
  end

  def self.fetch_scopus(batch_id, id)
    encoded_id = URI.encode_www_form_component(id)
    url = APP_CONFIG['forms_backend_url'] + "/api/scopus/" + encoded_id
    response = Net::HTTP.get_response(URI(url))
    status_code = response.code.to_i
    if status_code == 200
      begin
        json_response = JSON.parse(response.body)
        db_ready = scopus_to_db(batch_id, id, json_response)
        if db_ready.nil?
          return error_object(batch_id, id, "No valid article found in Scopus response")
        end
        return db_ready
      rescue JSON::ParserError
        return error_object(batch_id, id, "Invalid JSON response from Scopus")
      rescue => e
        return error_object(batch_id, id, "Error processing Scopus data: #{e.message}")
      end
    else
      return error_object(batch_id, id, "Failed to fetch from Scopus, status code: #{status_code}")
    end
  end

  def self.error_object(batch_id, request_id, error_message)
    {
      request_id: request_id,
      batch_id: batch_id,
      processed: false,
      error: error_message
    }
  end

  def self.pubmed_to_db(batch_id, request_id, data)
    first_id = data["result"]["uids"][0]
    article = data["result"][first_id]
    if article.nil?
      return nil
    end
    if article["error"]
      return nil
    end
    # Now we should have a valid article

    db_ready = {}
    db_ready[:request_id] = request_id
    db_ready[:batch_id] = batch_id
    db_ready[:processed] = false
    db_ready[:article_title] = article["title"] || ""
    db_ready[:journal_title] = article["fulljournalname"] || ""
    db_ready[:issn] = article["issn"] || ""
    db_ready[:publication_year] = article["pubdate"] || ""
    db_ready[:volume] = article["volume"] || ""
    db_ready[:pages] = article["pages"] || ""
    db_ready[:issue] = article["issue"] || ""
    authors = []
    if article["authors"]
      article["authors"].each do |author|
        authors << author["name"] if author["name"]
      end
    end
    db_ready[:authors] = authors.join(", ")
    db_ready[:item_identifier] = first_id
    db_ready[:item_identifier_source] = "pubmed"
    return db_ready
  end

  def self.scopus_to_db(batch_id, request_id, data)
    db_ready = {}
    db_ready[:request_id] = request_id
    db_ready[:batch_id] = batch_id
    db_ready[:processed] = false
    db_ready[:article_title] = data["title"] || ""
    db_ready[:journal_title] = data["journal_title"] || ""
    db_ready[:issn] = data["issn"] || ""
    db_ready[:publication_year] = data["pubyear"] || ""
    db_ready[:volume] = data["volume"] || ""
    db_ready[:pages] = data["pages"] || ""
    db_ready[:issue] = data["issue"] || ""
    db_ready[:authors] = data["authors"] || ""
    db_ready[:item_identifier] = request_id
    db_ready[:item_identifier_source] = "scopus"
    return db_ready
  end

  # {"batchId"=>nil, "orderListIds"=>"sadf", "allItems"=>"[]", "itemsFailed"=>"", "errors"=>"[]", "pickupLocationId"=>"7", "name"=>nil, "company1"=>nil, "company2"=>nil, "company3"=>nil, "emailAddress"=>nil, "xAccount"=>"adsf", "authenticatedXAccount"=>nil, "customerTypeId"=>"1", "deliveryMethodId"=>"2", "invoicingName"=>nil, "invoicingCompany"=>nil, "invoicingAddress"=>nil, "invoicingPostalAddress1"=>nil, "invoicingPostalAddress2"=>nil, "invoicingId"=>nil, "deliveryAddress"=>nil, "deliveryBox"=>nil, "deliveryPostalCode"=>nil, "deliveryCity"=>nil, "comments"=>nil},

  # Assume a hash with string keys in camelCase, convert to symbol keys and snake_case.
  # "allItems" and "errors" must also be JSON-parsed because they are sent as strings with stringified arrays.
  # Some names are changed.
  def self.to_local_params(params)
    new = {}
    new[:batch_id] = params["batchId"]
    new[:request_ids] = params["orderListIds"]
    new[:all_items] = params["allItems"].present? ? JSON.parse(params["allItems"], symbolize_names: true) : []
    new[:items_failed] = params["itemsFailed"]
    new[:errors] = params["errors"].present? ? JSON.parse(params["errors"], symbolize_names: true) : []
    new[:pickup_location_id] = params["pickupLocationId"].to_i
    new[:name] = params["name"]
    new[:company1] = params["company1"]
    new[:company2] = params["company2"]
    new[:company3] = params["company3"]
    new[:email_address] = params["emailAddress"]
    new[:x_account] = params["xAccount"]
    new[:authenticated_x_account] = params["authenticatedXAccount"]
    new[:customer_type_id] = params["customerTypeId"].to_i
    new[:delivery_method_id] = params["deliveryMethodId"].to_i
    new[:invoicing_name] = params["invoicingName"]
    new[:invoicing_address] = params["invoicingAddress"]
    new[:invoicing_postal_address1] = params["invoicingPostalAddress1"]
    new[:invoicing_postal_address2] = params["invoicingPostalAddress2"]
    new[:invoicing_id] = params["invoicingId"]
    new[:delivery_address] = params["deliveryAddress"]
    new[:delivery_box] = params["deliveryBox"]
    new[:delivery_postal_code] = params["deliveryPostalCode"]
    new[:delivery_city] = params["deliveryCity"]
    new[:comments] = params["comments"]
    return new
  end

  def self.from_local_params(params)
    new = {}
    new["batchId"] = params[:batch_id]
    new["orderListIds"] = params[:request_ids]
    new["allItems"] = params[:all_items].to_json
    new["itemsFailed"] = params[:items_failed]
    new["errors"] = params[:errors].to_json
    new["pickupLocationId"] = params[:pickup_location_id]
    new["name"] = params[:name]
    new["company1"] = params[:company1]
    new["company2"] = params[:company2]
    new["company3"] = params[:company3]
    new["emailAddress"] = params[:email_address]
    new["xAccount"] = params[:x_account]
    new["authenticatedXAccount"] = params[:authenticated_x_account]
    new["customerTypeId"] = params[:customer_type_id]
    new["deliveryMethodId"] = params[:delivery_method_id]
    new["invoicingName"] = params[:invoicing_name]
    new["invoicingAddress"] = params[:invoicing_address]
    new["invoicingPostalAddress1"] = params[:invoicing_postal_address1]
    new["invoicingPostalAddress2"] = params[:invoicing_postal_address2]
    new["invoicingId"] = params[:invoicing_id]
    new["deliveryAddress"] = params[:delivery_address]
    new["deliveryBox"] = params[:delivery_box]
    new["deliveryPostalCode"] = params[:delivery_postal_code]
    new["deliveryCity"] = params[:delivery_city]
    new["comments"] = params[:comments]
    return new
  end
end
