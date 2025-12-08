class BatchImportController < ApplicationController
  before_action :validate_token

  # POST /batch_import
  # Used to validate basic data and fetch metadata from sources based on request_ids.
  def create
    data = BatchImport.to_local_params(params["orderBatchRequest"])
    create_fetch_from_ids(data)
  end

  # PUT /batch_import/:batch_id
  # Used to create orders from a batch import, based on user selection.
  def update
    batch_id = params[:batch_id]
    data = BatchImport.to_local_params(params["orderBatchRequest"])
    create_orders_from_batch(batch_id, data)
  end

  def create_fetch_from_ids(data)
    validation_result = BatchImport.validate_params(data)
    # Returns array of errors, or empty array if all good.
    if validation_result.present?
      # Error: Add validation_results to params.errors and return 422
      # with full object.
      data[:errors] = validation_result
      data = BatchImport.from_local_params(data)
      render json: {"orderBatchRequest" => data}, status: 422
    else
      # All good, import from ids.
      batch_id = BatchImport.fetch_batch_id()
      # Results is a hash "import_results" and "failed_imports"
      results = BatchImport.fetch_batch(batch_id, data[:request_ids])
      data[:all_items] = results["import_results"]
      data[:items_failed] = results["failed_imports"].join("\n")
      data[:batch_id] = batch_id
      data = BatchImport.from_local_params(data)
      render json: {"orderBatchRequest" => data}, status: 200
    end
  end

  def create_orders_from_batch(batch_id, data)
    # In data[:all_items], loop through all items that has success: true and selected: true
    # Create one order per item, and in its item hash, add order.id and order.order_number
    # Metadata from sources are stored in the batch_imports table.
    if batch_id.nil? || batch_id.to_s !~ /^\d+$/
      render json: {error: {msg: "Invalid or missing batch_id"}}, status: 400
      return
    end
    batch_id = batch_id.to_i
    items = data[:all_items]
    if items.nil? || !items.is_a?(Array)
      render json: {error: {msg: "Missing or invalid all_items parameter"}}, status: 400
      return
    end
    created_orders = []
    items = items.map do |item|
      if item[:success] && item[:selected]
        begin
          order = BatchImport.create_order_from_item(batch_id, item, data, @current_user)
          item[:order_id] = order.id
          item[:order_number] = order.order_number
          item
        rescue => e
          # Log error but continue with other items
          Rails.logger.error("Error creating order from batch import item #{item[:request_id]}: #{e.message}")
          item[:error] = "Error creating order: #{e.message}"
          item
        end
      else
        item
      end
    end
    data[:all_items] = items
    data = BatchImport.from_local_params(data)
    render json: {"orderBatchRequest" => data}, status: 200
  end

  def show
    # TODO!
  end
end