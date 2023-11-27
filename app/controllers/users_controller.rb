class UsersController < ApplicationController
  before_action :validate_token

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

  def create
    logger.info "UsersController#create: Begins"
    status = 500

    user = User.new(permitted_params)

    if user.save!
      logger.info "UsersController#update: Object successfully saved."
      status = 201
      logger.info "============================================"
      logger.info "==== Here is json for the created User ==="
      logger.info "#{user.as_json}"
      logger.info "============================================"
    end

    logger.info "UsersController#create: Ends"
    render json: {user: user}, status: 201

  rescue ActiveRecord::RecordInvalid => error
    logger.error "UsersController#create: Error saving a user:"
    logger.error "#{user.errors}"
    render json: {errors: user.errors}, status: 400

  rescue => error
    logger.error "UsersController#create: Error creating a user:"
    logger.error "#{error.backtrace}"
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

  def update
    user_id = params[:id]
    user = User.find_by_id(user_id)
    # TBD: check user
    if user
      user.update_attributes(permitted_params)
      if user.save!
        logger.info "UsersController#update: User successfully saved."
        status = 200
        logger.info "==== Here is json for the stored object ===="
        logger.info "#{user.as_json}"
        logger.info "============================================"
      end
      render json: {user: user}, status: 200
    else
      render json: {}, status: 404
    end

  rescue ActiveRecord::RecordInvalid => error
    logger.error "UsersController#update: Error updating a user:"
    logger.error "#{user.errors}"
    render json: {errors: user.errors}, status: 400

  rescue => error
    logger.error "UsersController#create: Error updating a user:"
    logger.error "#{error.backtrace}"
    render json: {}, status: 500    
  end

  def delete
    render json: {}, status: 501
  end

private
  def permitted_params
    params.require(:user).permit([:xkonto,:managing_group_id, :pickup_location_id, :name])
  end
end
