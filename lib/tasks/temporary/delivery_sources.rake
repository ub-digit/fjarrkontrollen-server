namespace :delivery_sources do

  desc "Shorten names and change weight"
  task shorten_names_change_weight: :environment do
    puts "Adjusting delivery source data"
    delivery_source = DeliverySource.find_by(label: 'libris')
    delivery_source.update(position: 0)

    delivery_source = DeliverySource.find_by(label: 'subito')
    delivery_source.update(position: 2)

    delivery_source = DeliverySource.find_by(label: 'own_collection')
    delivery_source.update(name: "Egen samling: Tryckt")
    delivery_source.update(position: 5)

    delivery_source = DeliverySource.find_by(label: 'own_collection_e_resource')
    delivery_source.update(name: "Egen samling: E-resurs")
    delivery_source.update(position: 10)

    delivery_source = DeliverySource.find_by(label: 'own_collection_card_catalogue')
    delivery_source.update(name: "Egen samling: Kortkat")
    delivery_source.update(position: 15)

  end
end
