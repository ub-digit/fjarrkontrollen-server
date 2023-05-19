namespace :order_types do

  desc "Set default managing group for order types"
  task set_default_managing_group: :environment do
    puts "Setting default managing group"

    mappings = {
      'photocopy' => 'copies',
      'loan' => 'loan',
      'photocopy_chapter' => 'copies',
      'score' => 'score',
      'microfilm' => 'microfilm'
    }

    mappings.each do |order_type_label, managing_group_label|
      order_type = OrderType.find_by(label: order_type_label)
      managing_group = ManagingGroup.find_by(label: managing_group_label)
      order_type.update(default_managing_group_id: managing_group.id)
    end
  end
end
