class PickupLocationsController < ApplicationController

  # Find all pickup_location and show them.
  def index
    objs = PickupLocation.all.order(:name_sv)
    if objs
      render json: {pickup_locations: objs}, status: 200
    else
      render json: {}, status: 500
    end
  rescue => error
    render json: {}, status: 500
  end

  # Find one pickup_location using id and show it.
  def show
    objid = params[:id]
    obj = PickupLocation.find_by_id(objid)
    if obj
      render json: {pickup_location: obj}, status: 200
    else
      render json: {}, status: 404
    end
  rescue => error
    render json: {}, status: 500
  end

  # Find one pickup_location using label and show it.
  def show_by_label
    objid = params[:label]
    obj = PickupLocation.find_by_label(objid)
    if obj
      render json: {pickup_location: obj}, status: 200
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
