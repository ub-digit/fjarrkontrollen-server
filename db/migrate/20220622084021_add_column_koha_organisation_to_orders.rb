class AddColumnKohaOrganisationToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :koha_organisation, :string
  end
end
