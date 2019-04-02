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

    order_type_id_to_managing_group_id = {
      OrderType.find_by_label("loan").id => ManagingGroup.find_by_label("loan").id,
      OrderType.find_by_label("photocopy").id => ManagingGroup.find_by_label("copies").id,
      OrderType.find_by_label("photocopy_chapter").id =>  ManagingGroup.find_by_label("copies").id,
      OrderType.find_by_label("microfilm").id => ManagingGroup.find_by_label("microfilm").id,
      OrderType.find_by_label("score").id => ManagingGroup.find_by_label("score").id
    }

    pickup_location_id_to_managing_group_id = {
      PickupLocation.find_by_label("G-plikt").id => ManagingGroup.find_by_label("G-legal-deposits").id,
      PickupLocation.find_by_label("G-inkop").id => ManagingGroup.find_by_label("G-acquisitions").id,
      PickupLocation.find_by_label("Ge-inkop").id => ManagingGroup.find_by_label("Ge-acquisitions").id,
      PickupLocation.find_by_label("Gm-inkop").id => ManagingGroup.find_by_label("Gm-acquisitions").id,
      PickupLocation.find_by_label("Gp-inkop").id => ManagingGroup.find_by_label("Gp-acquisitions").id,
      PickupLocation.find_by_label("Gk-inkop").id => ManagingGroup.find_by_label("Gk-acquisitions").id,
      PickupLocation.find_by_label("Ghdk-inkop").id => ManagingGroup.find_by_label("Ghdk-acquisitions").id,
      PickupLocation.find_by_label("Gumu-inkop").id => ManagingGroup.find_by_label("Gumu-acquisitions").id
    }

    Order.all.each do |order|
      if order.pickup_location_id && pickup_location_id_to_managing_group_id.key?(order.pickup_location_id)
        order.managing_group_id = pickup_location_id_to_managing_group_id[order.pickup_location_id]
        order.save!(validate: false)
      elsif order.order_type_id && order_type_id_to_managing_group_id.key?(order.order_type_id)
        order.managing_group_id = order_type_id_to_managing_group_id[order.order_type_id]
        order.save!(validate: false)
      end
    end
    # delivery_type??

    delivery_method_pickup_id = DeliveryMethod.find_by_label("pickup").id
    delivery_method_send_id = DeliveryMethod.find_by_label("send").id

    Order.all.each do |order|
      if order.delivery_place.present?
        if /hämtas/i =~ order.delivery_place
          order.delivery_method_id = delivery_method_pickup_id
        elsif /skickas/i =~ order.delivery_place
          order.delivery_method_id = delivery_method_send_id
        else
          order.delivery_method_id = delivery_method_pickup_id
        end
        order.save!(validate: false)
      else # Libris låntagarbeställningar?
        order.delivery_method_id = delivery_method_pickup_id
        order.save!(validate: false)
        puts "No delivery_place for order #{order.id}"
      end
    end
    puts " All done!"
  end
end
