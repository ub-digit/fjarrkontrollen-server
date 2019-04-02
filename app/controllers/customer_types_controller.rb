class CustomerTypesController < ApplicationController
  # Find all CustomerTypes and show them.
  def index
    customer_types = CustomerType.all.order(:name_sv)
    if customer_types
      render json: {customer_types: customer_types}, status: 200
    else
      render json: {}, status: 500
    end
  rescue => error
    render json: {}, status: 500
  end

  # Find one customerType using id and show it.
  def show
    id = params[:id]
    customer_type = CustomerType.find_by_id(id)
    if customer_type
      render json: {customer_types: customer_type}, status: 200
    else
      render json: {}, status: 404
    end
  rescue => error
    render json: {}, status: 500
  end

  # Find one CustomerType using label and show it.
  def show_by_label
    id = params[:label]
    customer_type = CustomerType.find_by_label(id)
    if customer_type
      render json: {customer_type: customer_type}, status: 200
    else
      render json: {}, status: 404
    end
  rescue => error
    render json: {}, status: 500
  end

end
