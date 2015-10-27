class DeliverySourcesController < ApplicationController

  def index
    objs = DeliverySource.all.order(:position)
    if objs
      render json: {delivery_sources: objs}, status: 200
    else
      render json: {}, status: 500
    end
  rescue => error
    render json: {}, status: 500
  end

  def show
    id = params[:id]
    obj = DeliverySource.find_by_id(id)
    if obj
      render json: {delivery_source: obj}, status: 200
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
