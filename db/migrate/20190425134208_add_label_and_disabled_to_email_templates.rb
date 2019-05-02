class AddLabelAndDisabledToEmailTemplates < ActiveRecord::Migration
  def change
    add_column :email_templates, :label, :string
    add_column :email_templates, :disabled, :boolean
  end
end
