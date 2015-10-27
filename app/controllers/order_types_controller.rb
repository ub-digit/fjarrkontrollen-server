class OrderTypesController < ApplicationController
  #before_filter :validate_token
  def index
    objs = OrderType.all
    if objs
      render json: {order_types: objs}, status: 200
    else
      render json: {}, status: 404
    end
  end

  def show
    objid = params[:id]
    obj = OrderType.find_by_id(objid)
    if obj
      render json: {order_type: obj}, status: 200
    else
      render json: {}, status: 404
    end
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
