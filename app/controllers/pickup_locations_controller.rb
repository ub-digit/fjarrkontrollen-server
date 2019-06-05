class PickupLocationsController < ApplicationController
  # Find all pickup_location and show them.
  def index
    show_only_available = params[:show_only_available].present? && params[:show_only_available] == 'true'
    if show_only_available
      objs = PickupLocation.all.where(is_active: true).where(is_available: true).order(:name_sv)
    else
      objs = PickupLocation.all.where(is_active: true).order(:name_sv)
    end
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
