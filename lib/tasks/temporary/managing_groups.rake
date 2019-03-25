namespace :managing_groups do
	desc "Create managing groups"
	task create: :environment do
		puts "Creating managing groups"

		ActiveRecord::Base.transaction do
      load(Rails.root.join('db', 'seeds', 'managing_groups.rb'))
      load(Rails.root.join('db', 'seeds', 'delivery_methods.rb'))
		end

		puts " All done!"
	end

	desc "Migrate managing groups data"
	task migrate_data: :environment do
		puts "Migrating managing groups data"

		PickupLocation.all.each do |pickup_location|
			if ["G", "Ge", "Gm", "Gp", "Gk", "Gcl", "Ghdk", "Gumu"].include?(pickup_location.label)
				pickup_location.update_attribute(:is_active, true)
			else
				pickup_location.update_attribute(:is_active, false)
			end
		end
    if false
		Order.all.each do |order|
			if order.order_type_id == OrderType.find_by_label("loan").id
				order.managing_group_id = ManagingGroup.find_by_label("loan").id
			elsif order.order_type_id == OrderType.find_by_label("photocopy").id
				order.managing_group_id = ManagingGroup.find_by_label("copies").id
			elsif order.order_type_id == OrderType.find_by_label("photocopy_chapter").id
				order.managing_group_id = ManagingGroup.find_by_label("copies").id
			elsif order.order_type_id == OrderType.find_by_label("microfilm").id
				order.managing_group_id = ManagingGroup.find_by_label("microfilm").id
			elsif order.order_type_id == OrderType.find_by_label("score").id
				order.managing_group_id = ManagingGroup.find_by_label("score").id
			end
			order.save!(validate: false)
		end
    # delivery_type??

		Order.all.each do |order|
			if order.pickup_location_id == PickupLocation.find_by_label("G-plikt").id
				order.managing_group_id = ManagingGroup.find_by_label("G-legal-deposits").id
			elsif order.pickup_location_id == PickupLocation.find_by_label("G-inkop").id
				order.managing_group_id = ManagingGroup.find_by_label("G-acquisitions").id
			elsif order.pickup_location_id == PickupLocation.find_by_label("Ge-inkop").id
				order.managing_group_id = ManagingGroup.find_by_label("Ge-acquisitions").id
			elsif order.pickup_location_id == PickupLocation.find_by_label("Gm-inkop").id
				order.managing_group_id = ManagingGroup.find_by_label("Gm-acquisitions").id
			elsif order.pickup_location_id == PickupLocation.find_by_label("Gp-inkop").id
				order.managing_group_id = ManagingGroup.find_by_label("Gp-acquisitions").id
			elsif order.pickup_location_id == PickupLocation.find_by_label("Gk-inkop").id
				order.managing_group_id = ManagingGroup.find_by_label("Gk-acquisitions").id
			elsif order.pickup_location_id == PickupLocation.find_by_label("Ghdk-inkop").id
				order.managing_group_id = ManagingGroup.find_by_label("Ghdk-acquisitions").id
			elsif order.pickup_location_id == PickupLocation.find_by_label("Gumu-inkop").id
				order.managing_group_id = ManagingGroup.find_by_label("Gumu-acquisitions").id
			end
			order.save!(validate: false)
		end

    end

		Order.all.each do |order|
			if order.delivery_place.present?
				if /hämtas/i =~ order.delivery_place
					order.delivery_method_id = DeliveryMethod.find_by_label("pickup").id
        elsif /skickas/i =~ order.delivery_place
					order.delivery_method_id = DeliveryMethod.find_by_label("send").id
				else
					order.delivery_method_id = DeliveryMethod.find_by_label("pickup").id
				end
				order.save!(validate: false)
			else # Libris låntagarbeställningar?
				order.delivery_method_id = DeliveryMethod.find_by_label("pickup").id
				order.save!(validate: false)
				puts "No delivery_place for order #{order.id}"
			end
		end
		puts " All done!"
  end
end
