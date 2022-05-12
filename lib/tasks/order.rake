namespace :order do
  desc "Clear data"
  task :clear_data, [:year] => :environment do |t, args|
    cleared_value = "Rensad data"
    anonymized_data = [:name, :company1, :company2, :company3, :phone_number, :email_address, :library_card_number,
                         :invoicing_name, :invoicing_address, :invoicing_postal_address1, :invoicing_postal_address2,
                         :delivery_address, :delivery_postal_code, :delivery_city, :x_account, :invoicing_company,
                         :delivery_box, :delivery_comments, :authenticated_x_account, :koha_borrowernumber].map{|field|[field, cleared_value]}.to_h.merge!(user_id: nil)

    orders = Order.where("orders.created_at < ?", args[:year].to_i.years.ago).joins(:status).where(statuses: {label: ["cancelled", "delivered", "returned"]})
    orders.update_all(anonymized_data)
    Note.joins(:note_type).where(note_types: {label: ["user", "email"]}).where(order_id: orders).update_all(message: cleared_value)
  end

  desc "Set to cancel"
  task :set_cancel, [:year] => :environment do |t, args|
    cancelled_id = Status.find_by_label("cancelled")
    Order.where("orders.created_at < ?", args[:year].to_i.years.ago).update_all(status_id: cancelled_id)
  end
end



#PROD
# rake task order:set_cancel[4]
# rake task order:clear_data[2]

#DEVEL
# rake task order:set_cancel[2]
# rake task order:clear_data[2]
