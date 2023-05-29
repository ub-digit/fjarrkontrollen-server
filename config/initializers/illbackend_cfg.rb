# -*- encoding : utf-8 -*-
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
   :address => ENV["ILL_SMTP_SERVER"],
   :port => ENV["ILL_SMTP_PORT"]
}
ActionMailer::Base.raise_delivery_errors = true

Illbackend::Application.config.email_settings = {
  :subject_prefix => ENV["ILL_EMAIL_SUBJECT_PREFIX"]
}

Illbackend::Application.config.librisill_settings = {
  :base_url => ENV["ILL_LIBRISILL_BASE_URL"]
}

# Usage:
# Illbackend::Application.config.printing[:logo_path]
Illbackend::Application.config.printing = {
  :logo_path => "app/assets/images/gu_flag_fjarrlan_printout.png",
  :slip_logo_path => "app/assets/images/gu_flag_bokslip_printout.png"
}

Illbackend::Application.config.pagination = {
  :orders_per_page => 50
}

Illbackend::Application.config.koha = {
  :write => true,
  :userid => ENV["ILL_KOHA_USER"],
  :password => ENV["ILL_KOHA_PASSWORD"],
  :create_bib_and_item_url => ENV["ILL_KOHA_SVC_URL"] + '/ill/add',
  :delete_bib_and_item_url => ENV["ILL_KOHA_SVC_URL"] + '/ill/remove',
  :update_bib_and_item_url => ENV["ILL_KOHA_SVC_URL"] + '/ill/update'
}

Illbackend::Application.config.export = {
  :dir => ENV["ILL_EXPORT_DIR"]
}
