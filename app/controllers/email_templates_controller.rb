class EmailTemplatesController < ApplicationController
  before_filter :validate_token

  def index
    logger.info "EmailTemplatesController#index: Begins"
    email_templates = EmailTemplate.all.order(:position)
    if email_templates
      logger.info "EmailTemplatesController#index: Ends"
      render json: {email_templates: email_templates}, status: 200     
    else
      logger.error "EmailTemplatesController#index: Error getting EmailTemplates:"
      logger.error "#{error.inspect}"
      render json: {}, status: 500    
    end
  rescue => error
    logger.error "EmailTemplatesController#index: Error getting EmailTemplates:"
    logger.error "#{error.inspect}"
    render json: {}, status: 500
  end

  def show
    logger.info "EmailTemplatesController#show: Begins"
    email_template = EmailTemplate.find_by_id(params[:id])
    if email_template
      logger.info "EmailTemplatesController#show: Ends"
      render json: {email_template: email_template}, status: 200
    else
      logger.info "EmailTemplatesController#show: Ends, found no EmailTemplate with id = #{params[:id]}"
      render json: {}, status: 404
    end
  rescue => error
    logger.error "EmailTemplatesController#show: Error finding EmailTemplate with id = #{params[:id]}"
    logger.error "#{error.inspect}"
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
