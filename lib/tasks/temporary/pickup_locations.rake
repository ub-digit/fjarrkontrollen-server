namespace :pickup_locations do
  desc "Updating pickup locations"
  task create_codes: :environment do
    puts "Creating codes"

    PickupLocation.find_by_label('G').update_attribute(:code, '44')
    PickupLocation.find_by_label('Ge').update_attribute(:code, '48')
    PickupLocation.find_by_label('Gp').update_attribute(:code, '47')
    PickupLocation.find_by_label('Gk').update_attribute(:code, '42')
    PickupLocation.find_by_label('Gumu').update_attribute(:code, '62')
    PickupLocation.find_by_label('Ghdk').update_attribute(:code, '60')
    PickupLocation.find_by_label('Gm').update_attribute(:code, '40')

    puts " All done!"
  end
end

