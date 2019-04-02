namespace :customer_types do
  desc "Create customer types"
  task create: :environment do
    puts "Creating customer types"

    ActiveRecord::Base.transaction do
      load(Rails.root.join('db', 'seeds', 'customer_types.rb'))
    end

    puts " All done!"
  end

  desc "Migrate customer types data"
  task migrate_data: :environment do
    puts "Migrating customer types data"

    OrderType.all.each do |order_type|
      order_type.update_attribute(
        :auth_required,
        ["loan", "score"].include?(order_type.label)
      )
    end

    normalize = {
      "univ - doktorand" => "univ",
      "doktorand" => "univ",
      "stud  (doktorand)" => "univ",
      "Forsk (FC) - Campus Linné" => "univ",
      " Forsk (FC) - Campus Linné" => "univ",
      "uni" => "univ",
      "student" => "stud",
      "före" => "ftag",
      "stat" => "ovri",
      "forsk" => "univ",
      "bibl" => "ovri",
      "almenhet" => "priv",
      "stud (doktorand  tillagt av AMH)" => "univ",
      "allmänhet" => "priv",
      "Univ" => "univ",
      "forskare" => "univ"
    }


    Order.all.each do |order|
      customer_type_label = order.customer_type_old

      if customer_type_label.present?
        if normalize.key?(customer_type_label)
          customer_type_label = normalize[customer_type_label]
        end
      else
        customer_type_label = 'unknown'
      end

      customer_type = CustomerType.find_by_label(customer_type_label)
      if customer_type
        order.customer_type_id = customer_type.id
      else
        raise "Unknown customer type label: #{customer_type_label}"
      end
      order.save!(validate: false)
    end
  end
end
