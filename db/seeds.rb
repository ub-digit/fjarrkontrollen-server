# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# load basic data
load(Rails.root.join( 'db', 'seeds', "email_templates.rb"))
load(Rails.root.join( 'db', 'seeds', "order_types.rb"))
load(Rails.root.join( 'db', 'seeds', "delivery_sources.rb"))
load(Rails.root.join( 'db', 'seeds', "statuses.rb"))
load(Rails.root.join( 'db', 'seeds', "status_groups.rb"))
load(Rails.root.join( 'db', 'seeds', "status_group_members.rb"))
load(Rails.root.join( 'db', 'seeds', "systemuser.rb"))

load(Rails.root.join( 'db', 'seeds', "locations.rb"))
load(Rails.root.join( 'db', 'seeds', "users.rb"))

if !Rails.env == "production" && File.exist?("#{Rails.root}/tmp/testindicator.file")
  # ladda testdata
  load(Rails.root.join( 'db', 'seeds', "testdata.rb"))
end
