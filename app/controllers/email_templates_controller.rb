class EmailTemplatesController < ApplicationController
  before_action :validate_token



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
    logger.info "EmailTemplatesController#create: Begins"
    status = 500

    template = EmailTemplate.new(permitted_params)

    if template.save!
      logger.info "EmailTemplatesController#update: Object successfully saved."
      status = 201
      logger.info "============================================"
      logger.info "==== Here is json for the created EmailTemplate ==="
      logger.info "#{template.as_json}"
      logger.info "============================================"
    end

    logger.info "EmailTemplatesController#create: Ends"
    render json: {email_template: template}, status: 201

  rescue => error
    logger.error "EmailTemplatesController#create: Error creating an order:"
    logger.error "#{error.backtrace}"
    render json: {}, status: 500
  end

  def update
    status = 500
    logger.info "EmailTemplatesController#update: Parameters are: #{params}"

    template_id = params[:id]
    template = EmailTemplate.find_by_id(template_id)

    if template
      logger.info "EmailTemplatesController#update: Object is valid, now updating it..."
      logger.info "EmailTemplatesController#update: EmailTemplate: #{params[:template]}"
      template.update_attributes(permitted_params)
      logger.info "EmailTemplatesController#update: Just updated attributes, now saving..."

      if template.save!(validate: false)
        logger.info "EmailTemplatesController#update: Object successfully saved."
        status = 200
        logger.info "==== Here is json for the template template ===="
        logger.info "#{template.as_json}"
        logger.info "============================================"
      else
        logger.info "EmailTemplatesController#update: Bad request!"
        status = 400
      end
    else
      status = 404
    end
    logger.info "EmailTemplatesController#update: Returning representation..."
    # -------------------------------------------------- #
    # Handle ember's need for email_template return  START
    # -------------------------------------------------- #
    if status==200
      render json: {emailTemplate: template}, status: status
    else
      render json: {}, status: status
    end
    # -------------------------------------------------- #
    # Handle ember's need for email_template return  END
    # -------------------------------------------------- #
  rescue => error
    logger.error "EmailTemplatesController#update: Error updating email_template with id = #{template_id}"
    logger.error "#{error.inspect}"
    render json: {}, status: 500
  end

  def destroy
    email_template = EmailTemplate.find_by_id(params[:id])
    if email_template.present?
      email_template.destroy
      render json: {}, status: 200
    end
    rescue => error
      logger.error "EmailTemplatesController#destroy: Error finding EmailTemplate with id = #{params[:id]}"
      logger.error "#{error.inspect}"
      render json: {}, status: 500
    end
end

private
def data_attributes
  [
  :subject_sv,
  :subject_en,
  :body_sv,
  :body_en,
  :created_at,
  :updated_at,
  :label,
  :disabled,
  :position,
  ]
end

def permitted_params
  params.require(:email_template).permit(data_attributes)
end


