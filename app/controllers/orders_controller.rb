class OrdersController < ApplicationController
  # Change this when authentication in illforms is implemented!
  #before_filter :validate_token
  before_filter :validate_token, only: [:index, :update]

  respond_to :json, :pdf
  require "prawn/measurement_extensions"

  # GET /orders/
  # Filters:
  # GET /orders/?currentLocation=location_id
  # GET /orders/?mediaType=media_type_id
  # GET /orders/?user=user_id
  # GET /orders/?status_group=status_group_id
  # GET /orders/?is_archived=
  # GET /orders/?delivery_source=delivery_source_id

  # Sorting:
  # GET /orders/?sortkey=
  # Pagination:
  # GET /orders/?page=


  def index
    pagination = {}
    query = {}

    search_term = params[:search_term] || ''
    sortfield = params[:sortfield] || 'created_at'
    sortdir = params[:sortdir] || 'DESC'

    user             = params[:user]

    is_archived_str  = params[:is_archived] || ''
    apply_archive_filter = false
    if is_archived_str.downcase.eql?('true') || is_archived_str.eql?('1')
      is_archived = true
      apply_archive_filter = true
    elsif is_archived_str.downcase.eql?('false') || is_archived_str.eql?('0')
      is_archived = false
      apply_archive_filter = true
    end

    to_be_invoiced_str  = params[:to_be_invoiced] || ''
    apply_to_be_invoiced_filter = false
    if to_be_invoiced_str.downcase.eql?('true') || to_be_invoiced_str.eql?('1')
      to_be_invoiced = true
      apply_to_be_invoiced_filter = true
    elsif to_be_invoiced_str.downcase.eql?('false') || to_be_invoiced_str.eql?('0')
      to_be_invoiced = false
      apply_to_be_invoiced_filter = true
    end


    current_location = params[:currentLocation] || ''
    current_location = '' if current_location.downcase.eql?('null')
    current_location = '' if current_location.eql?('0')
    current_location = '' if current_location.downcase.eql?('all')

    order_type = params[:mediaType] || ''
    order_type = '' if order_type.downcase.eql?('null')
    order_type = '' if order_type.eql?('0')
    order_type = '' if order_type.downcase.eql?('all')


    # Set status group to all if parameter is missing
    status_group     = params[:status_group] || 'all'
    status_group = 'all' if status_group.eql?('0')
    status_group = 'all' if status_group.eql?('null')
    status_group_obj = StatusGroup.find_by_label(status_group)
    status_group_obj ? apply_status_group_filter = true : apply_status_group_filter = false


    delivery_source = params[:delivery_source] || ''
    delivery_source_obj = DeliverySource.find_by_label(delivery_source)
    delivery_source_obj ? apply_delivery_source_filter = true : apply_delivery_source_filter = false

    @orders = Order.paginate(page: params[:page])
    if @orders.current_page > @orders.total_pages
      @orders = Order.paginate(page: 1)
    end

    if apply_archive_filter
      @orders = @orders.where(is_archived: is_archived)
    end

    if apply_to_be_invoiced_filter
      @orders = @orders.where(to_be_invoiced: to_be_invoiced)
    end

    if apply_delivery_source_filter
      @orders = @orders.where(delivery_source_id: delivery_source_obj[:id])
    end

    if apply_status_group_filter
      @orders = @orders.where(status_id: status_group_obj.statuses.map(&:id))
    end

    @orders = @orders.where(location_id:   current_location) if current_location.present?
    @orders = @orders.where(user_id:       user)            if user.present?
    @orders = @orders.where(order_type_id: order_type)       if order_type.present?


    if search_term.present?
      st = search_term.downcase
      #the_user = User.where("id = ?", st[/^\d+$/] ? search_term.to_i : nil)
      user_xkonto_hit = User.where("(xkonto LIKE ?)", "%#{st}%").select(:id)
      user_name_hit = User.where("(lower(name) LIKE ?)", "%#{st}%").select(:id)

      note_hits = Order.joins(:notes).where(
        "(lower(notes.message) LIKE ?)
          OR (lower(notes.subject) LIKE ?)",
        "%#{st}%",
        "%#{st}%").to_a
      note_hit_ids = Array.new()
      note_hits.to_a.each do |hit|
        note_hit_ids << hit[:id]
      end
      logger.debug "note_hit_ids: #{note_hit_ids}"

      @orders = @orders.where(
        "(lower(name) LIKE ?)
          OR (lower(title) LIKE ?)
          OR (lower(authors) LIKE ?)
          OR (lower(publication_year) LIKE ?)
          OR (lower(journal_title) LIKE ?)
          OR (lower(issn_isbn) LIKE ?)
          OR (lower(reference_information) LIKE ?)
          OR (lower(library_card_number) = ?)
          OR (lower(order_number) LIKE ?)
          OR (lower(comments) LIKE ?)
          OR (lower(libris_lf_number) = ?)
          OR (libris_request_id = ?)
          OR (lower(librisid) = ?)
          OR (lower(librismisc) LIKE ?)
          OR (user_id IN (?))
          OR (user_id IN (?))
          OR (id IN (?))",
        "%#{st}%",
        "%#{st}%",
        "%#{st}%",
        "%#{st}%",
        "%#{st}%",
        "%#{st}%",
        "%#{st}%",
        st,
        "%#{st}%",
        "%#{st}%",
        st,
        st[/^\d+$/] ? search_term.to_i : nil,
        st,
        "%#{st}%",
        user_xkonto_hit,
        user_name_hit,
        note_hit_ids
      )
    end

    logger.info "OrdersController#index: current_location = #{current_location}"
    logger.info "OrdersController#index: sortfield == #{sortfield}"
    logger.info "OrdersController#index: sortdir == #{sortdir}"

    @orders = @orders.order(sortfield)
    @orders = @orders.reverse_order if sortdir.upcase == 'DESC'

    pagination[:pages] = @orders.total_pages
    pagination[:page] = @orders.current_page
    pagination[:next] = @orders.next_page
    pagination[:previous] = @orders.previous_page

    query[:total] = @orders.total_entries

    logger.info @orders.to_sql
    logger.info "OrdersController#index: Now rendering orders..."
    render json: {orders: @orders, meta: {pagination: pagination, query: query}}, status: 200
  end

  # POST /orders/
  def create
    logger.info "OrdersController#create: Begins"
    status = 500
    #my_data = params[:order].to_hash
    obj = Order.new(permitted_params)

    if obj.save!
      logger.info "OrdersController#update: Object successfully saved."
      headers['location'] = "/orders/#{obj.id}"
      #headers['location'] = "#{:order_url}"
      status = 201
      logger.info "==== Here is Header Info ==================="
      logger.info "#{headers['location']}"
      logger.info "============================================"
      logger.info "==== Here is json for the created object ==="
      logger.info "#{obj.as_json}"
      logger.info "============================================"
    end

    # Set is_archived and to_be_invoiced to false
    obj.update_attribute(:is_archived, false)
    obj.update_attribute(:to_be_invoiced, false)

    # Set a new order_number based on id and timestamp. Also save the original order number if any (just for "backwards tracing", this should be removed when the illform database is obsolete.)
    if obj[:order_number].present?
      logger.info "OrdersController#create: Order number exists: #{obj[:order_number]}, save it in the org. order number field."
      #obj.update_attribute(:org_order_number, obj[:order_number])
    else
      logger.info "OrdersController#create: Order number does not exist."
    end
    logger.info "OrdersController#create: Creating an new order nummber"
    id = obj[:id]
    created_at = obj[:created_at]
    order_number = created_at.strftime("%Y%m%d%H%M%S") + id.to_s
    obj.update_attribute(:order_number, order_number)

    # If status does not exist, set status_id to "New"
    if obj[:status_id].blank?
      logger.info "OrdersController#create: Status id does not exist, set it to New."
      obj.update_attribute(:status_id, Status.find_by_label('new')[:id])
    end
    # Set location to the same library as the sigel
    if obj[:location_id].blank?
      logger.info "OrdersController#create: Location id does not exist, set it to the same as the sigel / label."
      if location = Location.find_by_label(obj[:form_library])
        location_id = location[:id]
      else
        location_id = nil # Change to default ?
      end
      obj.update_attribute(:location_id, location_id)
    end

    # Send mail to customer if email address is given.
    if obj.email_address
      logger.info("OrdersController#create: Sending email to customer")
      Mailer.confirmation(obj, location).deliver
    end

    logger.info "OrdersController#create: Ends"
    render json: {order: obj}, status: 201

  rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError => e
    logger.error "OrdersController#create: Error sending email:"
    logger.error "#{error.inspect}"
    render json: {order: obj}, status: 201

  rescue => error
    logger.error "OrdersController#create: Error creating an order:"
    logger.error "#{error.inspect}"
    render json: {}, status: 500
  end

  # PUT /orders/{id}
  # When order is modified sucessfully the method give the response code 200 ("OK").
  def update
    status = 500
    logger.info "OrdersController#update: Parameters are: #{params}"

    obj_id = params[:id]
    obj = Order.find_by_id(obj_id)

    # Get a copy of the order for log creation
    old_obj = Order.find_by_id(obj_id)

    if obj
      logger.info "OrdersController#update: Object is valid, now updating it..."
      logger.info "OrdersController#update: order: #{params[:order]}"
      obj.update_attributes(permitted_params)
      logger.info "OrdersController#update: Just updated attributes, now saving..."

      if obj.save!
        # Get the user id, for note event log creation
        user_id = AccessToken.find_by_token(get_token)[:user_id]
        handle_order_changes obj_id, user_id, old_obj, obj

        logger.info "OrdersController#update: Object successfully saved."
        status = 200
        logger.info "==== Here is json for the stored object ===="
        logger.info "#{obj.as_json}"
        logger.info "============================================"
      else
        logger.info "OrdersController#update: Bad request!"
        status = 400
      end
    else
      status = 404
    end
    logger.info "OrdersController#update: Returning representation..."
    # -------------------------------------------------- #
    # Handle ember's need for object return  START
    # -------------------------------------------------- #
    if status==200
      render json: {order: obj}, status: status
    else
      render json: {}, status: status
    end
    # -------------------------------------------------- #
    # Handle ember's need for object return  END
    # -------------------------------------------------- #
  rescue => error
    logger.error "OrdersController#update: Error updating Order with id = #{obj_id}"
    logger.error "#{error.inspect}"
    render json: {}, status: 500
  end

  def handle_order_changes order_id, user_id, old_order, new_order
    write_to_note = true
    log_entries = []

    # Check if the difference is sticky note
    if old_order[:sticky_note_id] != new_order[:sticky_note_id]
      write_to_note = false
    end


    # Check user difference
    if old_order[:user_id].blank? && new_order[:user_id].present?
      log_entries << "Handläggare ändrades från Ingen till #{User.find_by_id(new_order[:user_id])[:xkonto]}."
    elsif old_order[:user_id].present? && new_order[:user_id].blank?
      log_entries << "Handläggare ändrades från #{User.find_by_id(old_order[:user_id])[:xkonto]} till Ingen."
    elsif old_order[:user_id].present? && new_order[:user_id].present? && (old_order[:user_id] != new_order[:user_id])
      log_entries << "Handläggare ändrades från #{User.find_by_id(old_order[:user_id])[:xkonto]} till #{User.find_by_id(new_order[:user_id])[:xkonto]}."
    end

    # Kolla nullvärden alt. lägg in not null-villkor i datamodellen!
    # Check status difference
    if old_order[:status_id] != new_order[:status_id]
      log_entries << "Status ändrades från #{Status.find_by_id(old_order[:status_id])[:name_sv]} till #{Status.find_by_id(new_order[:status_id])[:name_sv]}."

      # If new status is "received" and order type is loan or score and system is configured to write to Koha, then try to create items in Koha
      if (new_order[:status_id] == Status.find_by_label("received").id &&
          [OrderType.find_by_label("loan")[:id], OrderType.find_by_label("score")[:id]].include?(new_order[:order_type_id]) &&
          Illbackend::Application.config.koha[:write])
        res = Koha.create_bib_and_item new_order
        if res
          log_entries << "Bibliografisk post och exemplarpost skapades i Koha."
        else
          log_entries << "Systemet misslyckades med att skapa bibliografisk post och beståndspost i Koha."
        end
      end

      # If new status is "returned" or "cancelled" and order type is loan or score and system is configured to write to Koha, then try to delete items in Koha
      if ([Status.find_by_label("returned").id, Status.find_by_label("cancelled").id].include?(new_order[:status_id]) &&
          [OrderType.find_by_label("loan")[:id], OrderType.find_by_label("score")[:id]].include?(new_order[:order_type_id]) &&
          Illbackend::Application.config.koha[:write])
        res = Koha.delete_bib_and_item new_order.order_number
        if res
          log_entries << "Bibliografisk post och exemplarpost togs bort i Koha."
        else
          log_entries << "Systemet misslyckades med att ta bort bibliografisk post och beståndspost i Koha."
        end
      end
    end

    # Check order type difference
    if old_order[:order_type_id] != new_order[:order_type_id]
      log_entries << "Beställningstyp ändrades från #{OrderType.find_by_id(old_order[:order_type_id])[:name_sv]} till #{OrderType.find_by_id(new_order[:order_type_id])[:name_sv]}."
    end

    # Check location difference
    if old_order[:location_id] != new_order[:location_id]
      log_entries << "Remittering ändrades från #{Location.find_by_id(old_order[:location_id])[:name_sv]} till #{Location.find_by_id(new_order[:location_id])[:name_sv]}."
    end

    # Check lending library difference
    if old_order[:lending_library].blank? && new_order[:lending_library].present?
      log_entries << "Utlånande bibliotek ändrades från Ingen till #{new_order[:lending_library]}."
    elsif old_order[:lending_library].present? && new_order[:lending_library].blank?
      log_entries << "Utlånande bibliotek ändrades från #{old_order[:lending_library]} till Ingen."
    elsif old_order[:lending_library].present? && new_order[:lending_library].present? && (old_order[:lending_library] != new_order[:lending_library])
      log_entries << "Utlånande bibliotek ändrades från #{old_order[:lending_library]} till #{new_order[:lending_library]}."
    end


    # Check delivery source difference
    if old_order[:delivery_source_id].blank? && new_order[:delivery_source_id].present?
      log_entries << "Levererad från ändrades från Ingen till #{DeliverySource.find_by_id(new_order[:delivery_source_id])[:name]}."
    elsif old_order[:delivery_source_id].present? && new_order[:delivery_source_id].blank?
      log_entries << "Levererad från ändrades från #{DeliverySource.find_by_id(old_order[:delivery_source_id])[:name]} till Ingen."
    elsif old_order[:delivery_source_id].present? && new_order[:delivery_source_id].present? && (old_order[:delivery_source_id] != new_order[:delivery_source_id])
      log_entries << "Levererad från ändrades från #{DeliverySource.find_by_id(old_order[:delivery_source_id])[:name]} till #{DeliverySource.find_by_id(new_order[:delivery_source_id])[:name]}."
    end

    # Check order attribute difference
    order_attr_changed = false
    order_attributes.each do |attr|
      if old_order[attr] != new_order[attr]
        order_attr_changed = true
      end
    end
    if order_attr_changed
      log_entries << "Orderkort ändrades."
    end
    # Check customer attribute difference
    customer_attr_changed = false
    customer_attributes.each do |attr|
      if old_order[attr] != new_order[attr]
        customer_attr_changed = true
      end
    end
    if customer_attr_changed
      log_entries << "Låntagarinformation ändrades."
    end

    # Check is_archived difference
    if old_order[:is_archived] != new_order[:is_archived]
      if new_order[:is_archived] == true
        log_entries << "Beställningen arkiverades."
      else
        log_entries << "Beställningen avarkiverades."
      end
    end

    if write_to_note && !log_entries.empty?
      msg = log_entries.join("\n")
      logger.info "Writing to Note: " + msg
      Note.create({user_id: user_id, order_id: order_id, message: msg, is_email: false})
    else
      logger.info "Nothing to write to Note"
    end
  end

  def generate_pdf obj
    if params[:layout] && params[:layout].eql?("delivery_note")
      generade_delivery_note_pdf obj
    else
      generate_order_pdf obj
    end
  end

  def generade_delivery_note_pdf obj
    md_value = 6
    location =  Location.find_by_id(obj.location_id) ? Location.find_by_id(obj.location_id).name_sv : ""
    location_email = Location.find_by_id(obj.location_id) ? Location.find_by_id(obj.location_id).email : "ditt bibliotek"
    order_type = OrderType.find_by_id(obj.order_type_id) ? OrderType.find_by_id(obj.order_type_id).name_sv : ""

    require 'barby'
    require 'barby/barcode/code_128'
    require 'barby/outputter/prawn_outputter'

    pdf = Prawn::Document.new :page_size=> 'A4', :margin=>[10.send(:mm), 120.send(:mm), 10.send(:mm), 12.send(:mm)]
    pdf.font_families.update("Roboto" => {:normal => "lib/fonts/Roboto-Regular.ttf", :bold => "lib/fonts/Roboto-Bold.ttf"})
    pdf.font "Roboto"

    barcode = Barby::Code128B.new("#{obj.order_number}")
    current_date = Time.now.strftime("%F")

    # quick and dirty fix, set width to a large value to avoid line break for long names.
    pdf.bounding_box([0, pdf.cursor], :width => 200.send(:mm)) do
      pdf.text "#{obj.name} ", :size=>14, :style=>:bold
      pdf.text "#{obj.library_card_number} ", :size=>14

      pdf.move_down md_value * 2

      pdf.text "Återlämningsdatum ", :size=>11, :style=>:bold
      if obj.loan_period
        pdf.text "#{obj.loan_period} ", :size=>11
      else
        pdf.text "Inget, öppen lånetid ", :size=>11
      end
    end

    pdf.move_down md_value * 2

    pdf.text "#{obj.order_number}", :size=>12

    pdf.move_down md_value / 2

    barcode_cursor = pdf.cursor - 10.send(:mm)
    barcode.annotate_pdf(pdf, {:x=>0, :y=>barcode_cursor, :xdim => 0.8, :height=>(11.send(:mm))})


    pdf.move_down 20.send(:mm)
    pdf.line [0, pdf.cursor], [pdf.bounds.right, pdf.cursor]
    pdf.line_width 0.5
    pdf.stroke

    top_line_cursor = pdf.cursor

    pdf.move_down 24.send(:mm)
    pdf.text "Fjärrlån", :size=>24, :style=>:bold

    pdf.move_down 20.send(:mm)

    pdf.bounding_box([0, pdf.cursor], :width => 80.send(:mm)) do
      pdf.font_size = 11

      pdf.text "Titel", :style=>:bold
      pdf.text "#{obj.title} "
      pdf.move_down md_value

      if obj.price
        pdf.text "Pris", :style=>:bold
        pdf.text "#{obj.price} SEK"
        pdf.move_down md_value
      end
    end

    pdf.move_cursor_to top_line_cursor
    pdf.move_down 105.send(:mm)

    pdf.text "Vill du förnya ditt fjärrlån?", :size=>11, :style=>:bold
    pdf.text "Kontakta #{location_email} när lånetiden gått ut.", :size=>11
    pdf.move_down md_value * 8

    pdf.text "Låt den här följesedeln medfölja boken vid återlämning.", :size=>14, :style=>:bold

    pdf.move_cursor_to top_line_cursor
    pdf.move_down 157.send(:mm)
    pdf.text "#{location}", :style=>:bold
    pdf.move_down md_value

    pdf.line [0, pdf.cursor], [pdf.bounds.right, pdf.cursor]
    pdf.line_width 0.5
    pdf.stroke
    bottom_line_cursor = pdf.cursor

    pdf.move_cursor_to bottom_line_cursor

    pdf.move_down 10.send(:mm)

    pdf.bounding_box([0, pdf.cursor], :width => 200.send(:mm)) do
      pdf.text "#{obj.order_number}", :size=>12

      pdf.move_down md_value / 2

      barcode_cursor = pdf.cursor - 10.send(:mm)
      barcode.annotate_pdf(pdf, {:x=>0, :y=>barcode_cursor, :xdim => 0.8, :height=>(11.send(:mm))})
      pdf.move_down 16.send(:mm)

      pdf.text "#{obj.name} ", :size=>14, :style=>:bold
      pdf.text "#{obj.library_card_number} ", :size=>14

      pdf.move_down md_value * 2

      pdf.text "Återlämningsdatum ", :size=>11, :style=>:bold
      if obj.loan_period
        pdf.text "#{obj.loan_period} ", :size=>11
      else
        pdf.text "Inget, öppen lånetid ", :size=>11
      end
      pdf.move_down md_value * 2
    end



    pdf.image Illbackend::Application.config.printing[:slip_logo_path],
        :width=>20.send(:mm), :at=>[58.send(:mm), 205.send(:mm)]

    pdf.draw_text "#{current_date}", :size=>10, :rotate => 270, :at => [76.send(:mm),bottom_line_cursor - 10.send(:mm)]
    pdf.draw_text "#{current_date}", :size=>10, :rotate => 270, :at => [76.send(:mm),277.send(:mm)]

    send_data pdf.render, filename: "deliverynote-#{obj.order_number}.pdf", type: "application/pdf", disposition: "inline"

  end

  def generate_order_pdf obj
    md_value = 8
    status =  Status.find_by_id(obj.status_id) ? Status.find_by_id(obj.status_id).name_sv : ""
    location =  Location.find_by_id(obj.location_id) ? Location.find_by_id(obj.location_id).name_sv : ""
    user =  User.find_by_id(obj.user_id) ? User.find_by_id(obj.user_id).xkonto : ""
    order_type = OrderType.find_by_id(obj.order_type_id) ? OrderType.find_by_id(obj.order_type_id).name_sv : ""

    require 'barby'
    require 'barby/barcode/code_128'
    require 'barby/outputter/prawn_outputter'

    pdf = Prawn::Document.new :page_size=> 'A4', :margin=>[10.send(:mm), 20.send(:mm), 12.7.send(:mm), 20.send(:mm)]
    pdf.font_families.update("Roboto" => {:normal => "lib/fonts/Roboto-Regular.ttf", :bold => "lib/fonts/Roboto-Bold.ttf"})
    pdf.font "Roboto"

    pdf.move_down 2.7.send(:mm)

    pdf.text "Beställning", :size=>24, :style=>:bold
    pdf.move_down md_value*2

    pdf.text "#{obj.order_number}", :size=>16

    barcode_cursor = pdf.cursor - 15.send(:mm)
    barcode = Barby::Code128B.new("#{obj.order_number}")
    barcode.annotate_pdf(pdf, {:x=>0, :y=>barcode_cursor, :height=>(15.send(:mm))})

    pdf.font_size = 10

    pdf.move_down (15.send(:mm) + md_value)

    pdf.text "Handläggande enhet", :style=>:bold
    pdf.text "#{location} "
    pdf.move_down md_value*2

    pdf.font_size = 12

    pdf.bounding_box([0, pdf.cursor], :width => (126).send(:mm)) do
      pdf.text "Titel", :style=>:bold
      pdf.text "#{obj.title} "
      pdf.move_down md_value

      pdf.text "Författare", :style=>:bold
      pdf.text "#{obj.authors} "
      pdf.move_down md_value

      #pdf.transparent(0.5) { pdf.stroke_bounds}
    end

    pdf.move_down md_value*2
    top_line_cursor = pdf.cursor

    pdf.bounding_box([0, pdf.cursor], :width => 82.send(:mm)) do

      #stroke_bounds
      pdf.font_size = 10

      #my_cursor = pdf.cursor
      pdf.text "Tidskriftstitel", :style=>:bold
      pdf.text "#{obj.journal_title} "
      pdf.move_down md_value

      pdf.text "ISSN/ISBN", :style=>:bold
      pdf.text "#{obj.issn_isbn} "
      pdf.move_down md_value

      pdf.text "Publiceringsår", :style=>:bold
      pdf.text "#{obj.publication_year} "
      pdf.move_down md_value
      #pdf.transparent(0.8) { pdf.stroke_bounds}
      upper_right_col = pdf.cursor
    end

    pdf.bounding_box([87.send(:mm), top_line_cursor], :width => 82.send(:mm)) do
      pdf.text "Volym", :style=>:bold
      pdf.text "#{obj.volume} "
      pdf.move_down md_value

      pdf.text "Nummer", :style=>:bold
      pdf.text "#{obj.issue} "
      pdf.move_down md_value

      pdf.text "Sidor", :style=>:bold
      pdf.text "#{obj.pages} "
      pdf.move_down md_value

      if obj.comments
        pdf.text "Kommentar", :style=>:bold
        pdf.text "#{obj.comments} "
        pdf.move_down md_value
      end

      if obj.price
        pdf.text "Pris", :style=>:bold
        pdf.text "#{obj.price} SEK"
        pdf.move_down md_value
      end

      #pdf.transparent(0.5) { pdf.stroke_bounds}
      upper_left_col = pdf.cursor
    end

    pdf.move_down md_value*2
    pdf.line [0, pdf.cursor], [pdf.bounds.right, pdf.cursor]
    pdf.stroke
    pdf.move_down md_value*2

    middle_line_cursor = pdf.cursor

    pdf.bounding_box([0, middle_line_cursor], :width => 82.send(:mm)) do
      pdf.text "Namn", :style=>:bold
      pdf.text "#{obj.name} "
      pdf.move_down md_value

      if obj.company1 || obj.company2 || obj.company3
        pdf.text "Adress", :style=>:bold
        pdf.text "#{obj.company1} " unless !obj.company1
        pdf.text "#{obj.company2} " unless !obj.company2
        pdf.text "#{obj.company3} " unless !obj.company3
        pdf.move_down md_value
      end

      pdf.text "E-postadress", :style=>:bold
      pdf.text "#{obj.email_address} "
      pdf.move_down md_value

      if obj.library_card_number
        pdf.text "Lånekortsnummer", :style=>:bold
        pdf.text "#{obj.library_card_number} "
        pdf.move_down md_value
      end

      if obj.x_account
        pdf.text "X-konto", :style=>:bold
        pdf.text "#{obj.x_account} "
        pdf.move_down md_value
      end

      pdf.text "Kundtyp", :style=>:bold
      pdf.text "#{obj.customer_type} "
      pdf.move_down md_value

      if obj.not_valid_after
        pdf.text "Ej aktuell efter", :style=>:bold
        pdf.text "#{obj.not_valid_after} "
        pdf.move_down md_value
      end

      pdf.text "Beställningstyp", :style=>:bold
      pdf.text "#{order_type} "
      pdf.move_down md_value

      #pdf.transparent(0.5) { pdf.stroke_bounds}
      lower_right_col = pdf.cursor
    end

    pdf.bounding_box([87.send(:mm), middle_line_cursor], :width => 82.send(:mm)) do

      if obj.invoicing_name || obj.invoicing_address || obj.invoicing_postal_address1 || obj.invoicing_postal_address2 || obj.invoicing_id || obj.invoicing_company
        pdf.text "Faktureringsuppgifter", :style=>:bold
        pdf.text "#{obj.invoicing_name} " unless !obj.invoicing_name
        pdf.text "Beställar-ID: #{obj.invoicing_id} " unless !obj.invoicing_id
        pdf.text "#{obj.invoicing_company} " unless !obj.invoicing_company
        pdf.text "#{obj.invoicing_address} " unless !obj.invoicing_address
        pdf.text "#{obj.invoicing_postal_address1} " unless !obj.invoicing_postal_address1
        pdf.text "#{obj.invoicing_postal_address2} " unless !obj.invoicing_postal_address2
        pdf.move_down md_value
      end

      pdf.text "Leveransalternativ", :style=>:bold
      pdf.text "#{obj.delivery_place} "
      pdf.move_down md_value

      if obj.delivery_address || obj.delivery_postal_code || obj.delivery_box || obj.delivery_city || obj.delivery_comments
        pdf.text "Leveransuppgifter", :style=>:bold
        pdf.text "#{obj.delivery_address} " unless !obj.delivery_address
        pdf.text "#{obj.delivery_postal_code} " unless !obj.delivery_postal_code
        pdf.text "#{obj.delivery_box} " unless !obj.delivery_box
        pdf.text "#{obj.delivery_city} " unless !obj.delivery_city
        pdf.text "Kommentar: #{obj.delivery_comments} " unless !obj.delivery_comments
        pdf.move_down md_value
      end

      #pdf.transparent(0.5) { pdf.stroke_bounds}
      lower_left_col = pdf.cursor
    end
    pdf.image Illbackend::Application.config.printing[:logo_path],
        :width=>36.send(:mm), :at=>[(154-20).send(:mm), 777]

    pdf.move_cursor_to (7).send(:mm)
    pdf.line [0, pdf.cursor], [pdf.bounds.right, pdf.cursor]
    pdf.stroke

    pdf.move_cursor_to (5).send(:mm)

    pdf.text "Beställare: #{obj.name}"
    pdf.number_pages "<page>(<total>)", {:at=>[pdf.bounds.right - 20, 12], :size=>10}

    send_data pdf.render, filename: "order-#{obj.order_number}.pdf", type: "application/pdf", disposition: "inline"
  end

  # GET /orders/{id}
  def show
    obj = Order.find_by_id(params[:id])
    if obj
      respond_with do |format|
        format.json {render json: {order: obj}, status: 200}
        format.pdf  {generate_pdf obj}
      end
    else
      render json: {}, status: 404
    end
  rescue => error
    logger.error "OrdersController#show: Error finding Order with id = #{params[:id]}"
    logger.error "#{error.inspect}"
    render json: {}, status: 500
  end

  # GET /orders/{order_number}
  def show_by_order_number
    obj = Order.find_by(order_number: params[:order_number])
    if obj
      render json: {order: obj}, status: 200
    else
      render json: {}, status: 404
    end
  rescue => error
    logger.error "OrdersController#show_by_order_number: Error finding Order with id = #{params[:id]}"
    logger.error "#{error.inspect}"
    render json: {}, status: 500
  end

  # DELETE /orders/{id}
  def destroy
    status = 501
    render json: {}, status: 501
  end


private
  def metadata_attributes
    [:id,
     :order_number,
     :order_type_id,
     :location_id,
     :order_path,
     :status_id,
     :user_id,
     :libris_lf_number,
     :libris_request_id,
     :sticky_note_id,
     :lending_library,
     :is_archived,
     :delivery_source_id]
  end
  def order_attributes
    [:title,
     :publication_year,
     :volume,
     :issue,
     :pages,
     :journal_title,
     :issn_isbn,
     :librisid,
     :librismisc,
     :reference_information,
     :delivery_place, # move to customer ?
     :order_outside_scandinavia,
     :email_confirmation,
     :authors,
     :not_valid_after,
     :loan_period,
     :price,
     :to_be_invoiced,
     :publication_type,
     :period]
  end
  def customer_attributes
    [:name,
     :company1,
     :company2,
     :company3,
     :phone_number,
     :email_address,
     :library_card_number,
     :x_account,
     :customer_type,
     :comments,
     :form_lang,
     :form_library, # not present in view ?
     :invoicing_name,
     :invoicing_company,
     :invoicing_address,
     :invoicing_postal_address1,
     :invoicing_postal_address2,
     :invoicing_id,
     :delivery_address,
     :delivery_box,
     :delivery_postal_code,
     :delivery_city,
     :delivery_comments]
  end

  def permitted_params
    params.require(:order).permit(metadata_attributes + order_attributes + customer_attributes)
  end
end
