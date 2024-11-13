namespace :order_types do
  desc "Set default position for order types"
  task set_default_positions: :environment do
    puts "Setting positions"

    mappings = {
      'photocopy' => 0,
      'loan' => 1,
      'photocopy_chapter' => 2,
      'score' => 3,
      'microfilm' => 4
    }

    mappings.each do |order_type_label, position|
      order_type = OrderType.find_by(label: order_type_label)
      order_type.update(position: position)
    end
  end
end
