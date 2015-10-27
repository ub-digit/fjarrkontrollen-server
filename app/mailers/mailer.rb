# -*- encoding : utf-8 -*-

class Mailer < ActionMailer::Base
  def send_message(order_number, subject, message, from_email_address, to_email_address)
    @order_number = order_number
    @message = message
    mail(from:    from_email_address,
         to:      to_email_address, 
         subject: Illbackend::Application.config.email_settings[:subject_prefix] + subject)
  end

  def confirmation(order, location)
    @order = order
    @location = location
    set_locale order.form_lang ? order.form_lang.to_sym : :sv
    mail(from:    location.email,
         to:      order.email_address, 
         subject: Illbackend::Application.config.email_settings[:subject_prefix] + I18n.t('email.confirmation.subject') + order.order_number)
    set_default_locale
  end

private
  def set_locale locale
    I18n.locale = locale || I18n.default_locale
  end

  def set_default_locale
    I18n.locale = I18n.default_locale
  end
end

