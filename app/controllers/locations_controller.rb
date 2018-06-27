class LocationsController < ApplicationController
  #before_filter :validate_token

  # Find all location and show them.
  def index
    objs = Location.all.order(:name_sv)
    if objs
      render json: {locations: objs}, status: 200
    else
      render json: {}, status: 500
    end
  rescue => error
    render json: {}, status: 500
  end

  # Find one location using id and show it.
  def show
    objid = params[:id]
    obj = Location.find_by_id(objid)
    if obj
      render json: {location: obj}, status: 200
    else
      render json: {}, status: 404
    end
  rescue => error
    render json: {}, status: 500
  end

  # Find one location using label and show it.
  def show_by_label
    objid = params[:label]
    obj = Location.find_by_label(objid)
    if obj
      render json: {location: obj}, status: 200
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
