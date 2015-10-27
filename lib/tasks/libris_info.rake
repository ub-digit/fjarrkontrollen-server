namespace :libris_info do
  desc "Checks if there are orders with negative responses in Libris fjärrlån"
  task neg_responses: :environment do
    status_arch_id = Status.where(name_sv: "Arkiverad").first[:id]
    @orders =Order.where.not(status_id: status_arch_id)
    @orders.each do |obj|
      if obj[:libris_lf_number] && obj[:status_id] == Status.find_by_label('requested').id && obj[:delivery_source_id] == DeliverySource.find_by_label('libris').id
        lf_number = obj[:libris_lf_number]
        puts "lf_number:" + lf_number
        if LibrisILL.negative_response?(lf_number)
          # Get old status, for logging
          old_status = obj[:status_id]
          # Set status to Negativt svar från Libris
          obj.update_attribute(:status_id, Status.find_by_label('negative_response_libris').id)
          # Update Note
          msg = "Beställning uppdaterad.\n"
          msg << "Status ändrades från #{Status.find_by_id(old_status)[:name_sv]} till #{Status.find_by_id(obj[:status_id])[:name_sv]}."
          Note.create({user_id: 0, order_id: obj[:id], message: msg, is_email: false })
        end
      end
    end
  end

  desc "Checks if there are Libris enduser requests in Libris fjärrlån"
  task user_requests: :environment do
    @locations = Location.where(is_sigel: true)
    @locations.each do |location|
      location_id = location.id
      library_code = location.label
      puts "location_id:" + location_id.to_s
      puts "library_code:" + library_code
      resp = LibrisILL.get_user_requests library_code
      puts resp.inspect
      puts "Antal låntagarbeställningar: " + resp["count"].to_s

      # Get any Libris end user request for this library
      if resp["user_requests"]
        resp["user_requests"].each do |order|
          puts order
          libris_request_id = order["request_id"]

          # Check if the order already exists in fjärrkontrollen by the request_id
          if Order.find_by_libris_request_id(libris_request_id)
            puts "order already exist in fjärrkontrollen"
          else
            # Find out the order type
            if order["author_of_article"].present? || order["title_of_article"].present?
              # Order type should be photocopy
              order_type_id = OrderType.find_by_label("photocopy")[:id]
              title = order["title_of_article"].present? ? order["title_of_article"] : ""
              author = order["author_of_article"].present? ? order["author_of_article"] : ""
            else
              # Order type should be loan
              order_type_id = OrderType.find_by_label("loan")[:id]
              title = order["title"].present? ? order["title"] : ""
              authors = order["author"].present? ? order["author"] : ""
            end

            librismisc = ""
            order["place_of_publication"].present? ? librismisc << "place_of_publication: " + order["place_of_publication"] + "\n" : ""
            order["publisher"].present? ? librismisc << "publisher: " + order["publisher"] + "\n" : ""
            order["year"].present? ? librismisc << "year: " + order["year"] + "\n" : ""
            order["imprint"].present? ? librismisc << "imprint: " + order["imprint"] + "\n" : ""
            order["volume_designation"].present? ? librismisc << "volume_designation: " + order["volume_designation"] + "\n" : ""
            order["pages"].present? ? librismisc << "pages: " + order["pages"] + "\n" : ""
            order["article"].present? ? librismisc << "article: " + order["article"] + "\n" : ""
            order["response"].present? ? librismisc << "response: " + order["response"] + "\n" : ""

            obj = Order.new(
              # Order data
              is_archived: false,
              status_id: Status.find_by_label('new').id,
              location_id: location_id,
              order_type_id: order_type_id,
              libris_request_id: order["request_id"],
              order_path: "LibrisEnduser",
              title: title.present? ? title : nil,
              authors: authors.present? ? authors : nil,
              issn_isbn: order["isxn"].present? ? order["isxn"] : nil,
              librisid: order["bib_id"].present? ? order["bib_id"] : nil,
              librismisc: librismisc.present? ? librismisc : nil,
              order_outside_scandinavia: order["overseas"].present? && order["overseas"].eql?("true") ? true : false,
              email_confirmation: true,

              # End user data
              name: order["user"]["full_name"].present? ? order["user"]["full_name"] : nil,
              company1: order["user"]["address"].present? ? order["user"]["address"] : nil,
              company2: order["user"]["zip_code"].present? ? order["user"]["zip_code"] : nil,
              company3: order["user"]["city"].present? ? order["user"]["city"] : nil,
              phone_number: order["user"]["mobile"].present? ? order["user"]["mobile"] : nil,
              library_card_number: order["user"]["library_card"].present? ? order["user"]["library_card"] : nil,
              email_address: order["user"]["email"].present? ? order["user"]["email"] : nil
            )
            if obj.save!
              puts "beställning sparad"
              # Create an order number
              id = obj[:id]
              created_at = obj[:created_at]
              order_number = created_at.strftime("%Y%m%d%H%M%S") + id.to_s
              obj.update_attribute(:order_number, order_number)
              # Create a log entry note.
              msg = "Libris låntagarbeställning hämtad från Libris Fjärrlån.\n"
              msg << "Status ändrades från Ingen till #{Status.find_by_label('new')[:name_sv]}."
              Note.create({user_id: 0, order_id: obj[:id], message: msg, is_email: false })
            else
              puts "Fel vid sparande av beställning."
            end
          end
        end
      end
    end
  end
end
