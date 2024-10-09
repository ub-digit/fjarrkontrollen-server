class DeliveryMethodsController < ApplicationController
  #before_action :validate_token
  def index
    objs = DeliveryMethod.all
    if objs
      render json: {delivery_methods: objs}, status: 200
    else
      render json: {}, status: 500
    end
  rescue => error
    render json: {}, status: 500
  end

  def show
    id = params[:id]
    obj = DeliveryMethod.find_by_id(id)
    if obj
      render json: {delivery_method: obj}, status: 200
    else
      render json: {}, status: 404
    end
  rescue => error
    render json: {}, status: 500  
  end

  def create
    render json: {}, status: 501
  end

  def update
    render json: {}, status: 501
  end

  def delete
    render json: {}, status: 501
  end
end
