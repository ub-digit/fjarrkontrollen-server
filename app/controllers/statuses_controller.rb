class StatusesController < ApplicationController
  #before_filter :validate_token

  def index
    objs = Status.all.order(:position)
    if objs
      render json: {statuses: objs}, status: 200
    else
      render json: {}, status: 500
    end
  rescue => error
    render json: {}, status: 500
  end

  def show
    objid = params[:id]
    obj = Status.find_by_id(objid)
    if obj
      render json: {status: obj}, status: 200
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
