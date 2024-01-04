namespace :delivery_sources do
  desc "Split delivery source category other into other_sweden and other_other_countries"
  task split_other: :environment do
    puts "Split 'Annan' into 'Annan (övriga lander) and 'Annan (Sverige)'"
    delivery_source = DeliverySource.find_by(label: 'other')
    if delivery_source
      delivery_source.update(name: 'Annan (övriga länder)', label: "other_other_countries")
    end

    delivery_source = DeliverySource.find_by(label: 'other_sweden')
    unless delivery_source
      DeliverySource.create(name: "Annan (Sverige)", label: "other_sweden", position: 120)
    end
  end
end
