class UsersController < ApplicationController
  #before_filter :validate_token

  def index
    objs = User.all
    if objs
      render json: {users: objs}, status: 200
    else
      render json: {}, status: 500
    end
  rescue => error
    render json: {}, status: 500
  end

  def show
    objid = params[:id]
    obj = User.find_by_id(objid)
    if obj
      render json: {user: obj}, status: 200
    else
      render json: {}, status: 404
    end
  rescue => error
    render json: {}, status: 500
  end

  def show_by_xkonto
    objid = params[:xkonto]
    objid.downcase!
    obj = User.find_by_xkonto(objid)
    if obj
      render json: {user: obj}, status: 200
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
    user_id = params[:id]
    user = User.find_by_id(user_id)
    # TBD: check user
    if user
      user.update_attributes(permitted_params)
      render json: {user: user}, status: 200
    else
      render json: {}, status: 404
    end
  rescue => error
    render json: {}, status: 500
  end

  def delete
    render json: {}, status: 501
  end

private
  def permitted_params
    params.require(:user).permit([:managing_group_id, :pickup_location_id])
  end
end
