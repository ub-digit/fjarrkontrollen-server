namespace :customer_types do
	desc "Create customer types"
	task create: :environment do
		puts "Creating customer types"

		ActiveRecord::Base.transaction do
      load(Rails.root.join('db', 'seeds', 'customer_types.rb'))
		end

		puts " All done!"
	end
end
