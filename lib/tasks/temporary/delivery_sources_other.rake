namespace :delivery_sources do
  desc "Split delivery source category other into other_sweden and other_other_countries and set new order"
  task split_other: :environment do
    puts "Split 'Annan' into 'Annan (övriga lander) and 'Annan (Sverige) and set new order'"

    delivery_source = DeliverySource.find_by(label: 'libris')
    delivery_source.update(position: 10)

    delivery_source = DeliverySource.find_by(label: 'subito')
    delivery_source.update(position: 20)

    delivery_source = DeliverySource.find_by(label: 'own_collection')
    delivery_source.update(position: 30)

    delivery_source = DeliverySource.find_by(label: 'own_collection_card_catalogue')
    delivery_source.update(position: 40)

    delivery_source = DeliverySource.find_by(label: 'own_collection_e_resource')
    delivery_source.update(position: 50)

    delivery_source = DeliverySource.find_by(label: 'oclc')
    delivery_source.update(position: 60)

    delivery_source = DeliverySource.find_by(label: 'netpunkt')
    delivery_source.update(position: 70)

    delivery_source = DeliverySource.find_by(label: 'free_e-resource_other')
    delivery_source.update(position: 80)

    delivery_source = DeliverySource.find_by(label: 'free_e-resource')
    delivery_source.update(position: 90)

    delivery_source = DeliverySource.find_by(label: 'getitnow')
    delivery_source.update(position: 100)

    delivery_source = DeliverySource.find_by(label: 'reprints_desk')
    delivery_source.update(position: 110)

    delivery_source = DeliverySource.find_by(label: 'other')
    if delivery_source
      delivery_source.update(name: 'Annan (övriga länder)', label: "other_other_countries", position: 120)
    end

    delivery_source = DeliverySource.find_by(label: 'other_sweden')
    unless delivery_source
      DeliverySource.create(name: "Annan (Sverige)", label: "other_sweden", is_active: true, position: 130)
    end

    delivery_source = DeliverySource.find_by(label: 'bibsys')
    delivery_source.update(position: 140)

    delivery_source = DeliverySource.find_by(label: 'blld')
    delivery_source.update(position: 150)
  end
end
