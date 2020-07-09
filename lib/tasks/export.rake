namespace :export do
  desc "Creates an excel file with order data"
  task orders: :environment do
    book = Export.create
    book.write "#{Illbackend::Application.config.export[:dir]}orders.xls"
  end
end
