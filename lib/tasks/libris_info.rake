namespace :libris_info do
  desc "Checks if there are orders with negative responses in Libris fjärrlån"
  task neg_responses: :environment do
    status_arch_id = Status.where(label: "archived").first.id
    orders = Order.where.not(status_id: status_arch_id)
    orders.each do |order|
      if order.libris_lf_number && order.status_id == Status.find_by_label('requested').id && order.delivery_source_id == DeliverySource.find_by_label('libris').id
        lf_number = order.libris_lf_number
        puts "lf_number:" + lf_number
        if LibrisILL.negative_response?(lf_number)
          # Get old status, for logging
          old_status = order.status_id
          # Set status to Negativt svar från Libris
          order.update_attribute(:status_id, Status.find_by_label('negative_response_libris').id)
          # Update Note
          msg = "Beställning uppdaterad.\n"
          msg << "Status ändrades från #{Status.find_by_id(old_status).name_sv} till #{Status.find_by_id(order.status_id).name_sv}."
          Note.create({user_id: 0, order_id: order.id, message: msg, is_email: false})
        end
      end
    end
  end

  desc "Checks if there are Libris enduser requests in Libris fjärrlån"
  task user_requests: :environment do
    pickup_locations = PickupLocation.where(is_sigel: true)
    pickup_locations.each do |pickup_location|
      pickup_location_id = pickup_location.id
      library_code = pickup_location.label
      puts "pickup_location_id:" + pickup_location_id.to_s
      puts "library_code:" + library_code
      resp = LibrisILL.get_user_requests library_code
      puts resp.inspect
      puts "Antal låntagarbeställningar: " + resp["count"].to_s

      # Get any Libris end user request for this library
      if resp["user_requests"]
        resp["user_requests"].each do |user_request|
          puts user_request
          libris_request_id = user_request["request_id"]

          # Check if the order already exists in fjärrkontrollen by the request_id
          if Order.find_by_libris_request_id(libris_request_id)
            puts "order already exist in fjärrkontrollen"
          else
            # Find out the order type
            if user_request["author_of_article"].present? || user_request["title_of_article"].present?
              # Order type should be photocopy
              order_type_id = OrderType.find_by_label("photocopy").id
              managing_group_id = ManagingGroup.find_by_label("copies").id
              title = user_request["title_of_article"].present? ? user_request["title_of_article"] : ""
              author = user_request["author_of_article"].present? ? user_request["author_of_article"] : ""
            else
              # Order type should be loan etc
              order_type_id = OrderType.find_by_label("loan").id
              managing_group_id = ManagingGroup.find_by_label("loan").id
              title = user_request["title"].present? ? order["title"] : ""
              authors = user_request["author"].present? ? user_request["author"] : ""
            end

            librismisc = ""
            user_request["place_of_publication"].present? ? librismisc << "place_of_publication: " + user_request["place_of_publication"] + "\n" : ""
            user_request["publisher"].present? ? librismisc << "publisher: " + user_request["publisher"] + "\n" : ""
            user_request["imprint"].present? ? librismisc << "imprint: " + user_request["imprint"] + "\n" : ""
            user_request["volume_designation"].present? ? librismisc << "volume_designation: " + user_request["volume_designation"] + "\n" : ""
            user_request["article"].present? ? librismisc << "article: " + user_request["article"] + "\n" : ""
            user_request["response"].present? ? librismisc << "response: " + user_request["response"] + "\n" : ""

            order = Order.new(
              # Order data
              is_archived: false,
              status_id: Status.find_by_label('new').id,
              customer_type_id: CustomerType.find_by_label('unknown').id,
              pickup_location_id: pickup_location_id,
              managing_group_id: managing_group_id,
              order_type_id: order_type_id,
              libris_request_id: user_request["request_id"],
              order_path: "LibrisEnduser",
              title: title.present? ? title : nil,
              authors: authors.present? ? authors : nil,
              issn_isbn: user_request["isxn"].present? ? user_request["isxn"] : nil,
              publication_year: user_request["year"].present? ? user_request["year"] : nil,
              pages: user_request["pages"].present? ? user_request["pages"] : nil,
              librisid: user_request["bib_id"].present? ? user_request["bib_id"] : nil,
              librismisc: librismisc.present? ? librismisc : nil,
              order_outside_scandinavia: user_request["overseas"].present? && user_request["overseas"].eql?("true") ? true : false,
              email_confirmation: true,

              # End user data
              name: user_request["user"]["full_name"].present? ? user_request["user"]["full_name"] : nil,
              company1: user_request["user"]["address"].present? ? user_request["user"]["address"] : nil,
              company2: user_request["user"]["zip_code"].present? ? user_request["user"]["zip_code"] : nil,
              company3: user_request["user"]["city"].present? ? user_request["user"]["city"] : nil,
              phone_number: user_request["user"]["mobile"].present? ? user_request["user"]["mobile"] : nil,
              library_card_number: user_request["user"]["library_card"].present? ? user_request["user"]["library_card"] : nil,
              email_address: user_request["user"]["email"].present? ? user_request["user"]["email"] : nil
            )
            if order.save!
              puts "beställning sparad"
              # Create an order number
              id = order.id
              created_at = order.created_at
              order_number = created_at.strftime("%Y%m%d%H%M%S") + id.to_s
              order.update_attribute(:order_number, order_number)
              # Create a log entry note.
              msg = "Libris låntagarbeställning hämtad från Libris Fjärrlån.\n"
              msg << "Status ändrades från Ingen till #{Status.find_by_label('new').name_sv}."
              Note.create({user_id: 0, order_id: order.id, message: msg, is_email: false })
            else
              puts "Fel vid sparande av beställning."
            end
          end
        end
      end
    end
  end
end
