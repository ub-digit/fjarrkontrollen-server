namespace :export do
  desc "Creates an excel file with order data"
  task orders: :environment do
    axlsx_package = Export.create
    axlsx_package.serialize "#{Illbackend::Application.config.export[:dir]}orders.xlsx"
  end
end
