class ManagingGroupsController < ApplicationController
  before_filter :validate_token
  # Find all managing_group and show them.
  def index
    objs = ManagingGroup.all.order(:name)
    if objs
      render json: {managing_groups: objs}, status: 200
    else
      render json: {}, status: 500
    end
  rescue => error
    render json: {}, status: 500
  end

  # Find one managing_group using id and show it.
  def show
    objid = params[:id]
    obj = ManagingGroup.find_by_id(objid)
    if obj
      render json: {managing_group: obj}, status: 200
    else
      render json: {}, status: 404
    end
  rescue => error
    render json: {}, status: 500
  end

  # Find one managing_group using label and show it.
  def show_by_label
    objid = params[:label]
    obj = ManagingGroup.find_by_label(objid)
    if obj
      render json: {managing_group: obj}, status: 200
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
