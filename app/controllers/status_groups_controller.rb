class StatusGroupsController < ApplicationController
  #before_filter :validate_token

  def index
    status_groups = StatusGroup.all.order(:position)
    if status_groups
      render json: {status_groups: status_groups}, status: 200
    else
      render json: {}, status: 500
    end
  rescue => error
    render json: {}, status: 500
  end

  def show
    objid = params[:id]
    status_group = StatusGroup.find_by_id(objid)
    if status_group
      render json: {status_group: status_group}, status: 200
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
