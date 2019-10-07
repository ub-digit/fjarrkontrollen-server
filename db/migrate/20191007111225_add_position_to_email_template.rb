class AddPositionToEmailTemplate < ActiveRecord::Migration
  def change
  	add_column :email_templates, :position, :integer
  end
end
