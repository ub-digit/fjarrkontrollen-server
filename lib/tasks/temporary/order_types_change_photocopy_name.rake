namespace :order_types do
  desc "Change name for order type photocopy"
  task order_type_photocopy_change_name: :environment do
    puts "Changing name for order type copy"
    order_type = OrderType.find_by(label: 'photocopy')
    order_type.update(name_sv: 'Artikelkopia')
  end
end
