namespace :users do
  desc "Migrate users data"
  task migrate_data: :environment do
    puts "Migrating users data"

    pickup_location_id_to_managing_group_id = {
      PickupLocation.find_by_label("G").id => ManagingGroup.find_by_label("loan").id,
      PickupLocation.find_by_label("Ge").id => ManagingGroup.find_by_label("loan").id,
      PickupLocation.find_by_label("Gk").id => ManagingGroup.find_by_label("microfilm").id,
      PickupLocation.find_by_label("Gp").id => ManagingGroup.find_by_label("loan").id,
      PickupLocation.find_by_label("Gm").id => ManagingGroup.find_by_label("copies").id,
      PickupLocation.find_by_label("Gumu").id => ManagingGroup.find_by_label("score").id,
      PickupLocation.find_by_label("Ghdk").id => ManagingGroup.find_by_label("loan").id,

      PickupLocation.find_by_label("G-plikt").id => ManagingGroup.find_by_label("G-legal-deposits").id,
      PickupLocation.find_by_label("G-inkop").id => ManagingGroup.find_by_label("G-acquisitions").id,
      PickupLocation.find_by_label("Ge-inkop").id => ManagingGroup.find_by_label("Ge-acquisitions").id,
      PickupLocation.find_by_label("Gm-inkop").id => ManagingGroup.find_by_label("Gm-acquisitions").id,
      PickupLocation.find_by_label("Gp-inkop").id => ManagingGroup.find_by_label("Gp-acquisitions").id,
      PickupLocation.find_by_label("Gk-inkop").id => ManagingGroup.find_by_label("Gk-acquisitions").id,
      PickupLocation.find_by_label("Ghdk-inkop").id => ManagingGroup.find_by_label("Ghdk-acquisitions").id,
      PickupLocation.find_by_label("Gumu-inkop").id => ManagingGroup.find_by_label("Gumu-acquisitions").id
    }

    User.where.not(xkonto: ["xg00618","xg00621","xg00627","xg00625","xg00622","xg00636","xg00713"]).each do |user|
      if user.pickup_location_id && pickup_location_id_to_managing_group_id.key?(user.pickup_location_id)
        user.managing_group_id = pickup_location_id_to_managing_group_id[user.pickup_location_id]
        user.pickup_location_id = nil
        user.save!
      end
    end
  end
end