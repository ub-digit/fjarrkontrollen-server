class NotesController < ApplicationController
  before_action :validate_token

  def index
    logger.info "NotesController#index: Begins"
    if params[:order_id]
      # Get sticky note if any
      sticky_note_id = Order.find_by_id(params[:order_id]).sticky_note_id
      notes = Note.where(id: sticky_note_id) + Note.where.not(id: sticky_note_id).where(order_id: params[:order_id]).where(deleted_at: nil).order(created_at: :desc)
    else
      notes = Note.where(deleted_at: nil).order(created_at: :desc)
    end
    logger.info "NotesController#create: Ends"
    render json: {notes: notes}, status: 200

  rescue => error
    logger.error "NotesController#index: Error listing notes:"
    logger.error "#{error.inspect}"
    render json: {}, status: 500
  end

  def create
    logger.info "NotesController#create: Begins"
    # Check if we will send email
    if !params[:note][:is_email].nil? && params[:note][:is_email]
      logger.info "NotesController#create: This note is an email, trying to send it..."

      order_id = params[:note][:order_id]
      logger.info "NotesController#create: Current order has order_id: " + order_id

      # Get the order object
      order = Order.find(order_id)
      # Get the email adddress in the order
      to = order.email_address

      subject = !params[:note][:subject].nil? ? params[:note][:subject] : subject = ""
      message = !params[:note][:message].nil? ? params[:note][:message] : message = ""

      # Get the proper from email address
      from = get_from_email_address(params[:note][:email_template_label], order)

      logger.info "NotesController#create: Sending the note by email, #{from} -> #{to}"

      begin
        Mailer.send_message(order.order_number, subject, message, from, to).deliver_now
        logger.info "NotesController#create: Email sent with no known exceptions from SMTP server."
      rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => error
        logger.error "NotesController#create: Error sending email:"
        logger.error "#{error.inspect}"
        render json: {}, status: 500
        return
      end
    end

    obj = Note.new(permitted_params)

    if obj.save!
      logger.info "NotesController#update: Object successfully saved."
      logger.info "==== Here is json for the created object ==="
      logger.info "#{obj.as_json}"
      logger.info "============================================"
    end

    logger.info "NotesController#create: Ends"
    render json: {note: obj}, status: 201
    #render json: {}, status: 201
  rescue => error
    logger.error "NotesController#create: Error creating an note:"
    logger.error "#{error.inspect}"
    render json: {}, status: 500
  end


  def show
    logger.info "NotesController#show: Begins"
    obj = Note.find_by_id(params[:id])
    if obj
      render json: {note: obj}, status: 200
    else
      render json: {}, status: 404
    end
  rescue => error
    logger.error "NotesController#show: Error finding Note with id = #{params[:id]}"
    logger.error "#{error.inspect}"
    render json: {}, status: 500
  end



  def update
    status = 500
    logger.info "NotesController#update: Parameters are: #{params}"
    logger.info "NotesController#update: Headers are..."
    logger.info "-------- ======== -------- ======== --------"
    #request.headers.each do |header|
    #  logger.info "NotesController#update: #{header}"
    #end
    logger.info "-------- ======== -------- ======== --------"

    obj_id = params[:id]
    obj = Note.find_by_id(obj_id)

    if obj
      logger.info "NotesController#update: Object is valid, now updating it..."
      logger.info "NotesController#update: notes: #{params[:order]}"
      obj.update(permitted_params)
      logger.info "NotessController#update: Just updated attributes, now saving..."

      if obj.save!
        logger.info "NotesController#update: Object successfully saved."
        status = 200
        logger.info "==== Here is json for the stored object ===="
        logger.info "#{obj.as_json}"
        logger.info "============================================"
      else
        logger.info "NotesController#update: Bad request!"
        status = 400
      end
    else
      status = 404
    end
    logger.info "NotesController#update: Returning representation..."
    # -------------------------------------------------- #
    # Handle ember's need for object return  START
    # -------------------------------------------------- #
    if status==200
      render json: {note: obj}, status: status
    else
      render json: {}, status: status
    end
    # -------------------------------------------------- #
    # Handle ember's need for object return  END
    # -------------------------------------------------- #
  rescue => error
    logger.error "NotesController#update: Error updating Note with id = #{obj_id}"
    logger.error "#{error.inspect}"
    render json: {}, status: 500
  end


  def destroy
    logger.info "NotesController#destroy: Begins"
    note = Note.find_by_id(params[:id])

    if note.present?
      note.update({deleted_at: DateTime.now, deleted_by: @current_user.xkonto})
      render json: {}, status: 200
    else
      render json: {}, status: 404
    end
  rescue => error
    logger.error "NotesController#destroy: Error finding Note with id = #{params[:id]}"
    logger.error "#{error.inspect}"
    render json: {}, status: 500
  end


  private
  def get_from_email_address template, order
    case template
    when 'copies_to_collect'
      order.pickup_location.email
    when 'delivered_status_set_for_copies_to_collect'
      order.pickup_location.email
    else
      order.managing_group.email 
    end
  end

  def permitted_params
    params.require(:note).permit(:id, :order_id, :subject, :message, :user_id, :is_email, :note_type_id)
  end
end
