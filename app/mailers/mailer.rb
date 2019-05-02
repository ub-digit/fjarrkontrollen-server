# -*- encoding : utf-8 -*-

class Mailer < ActionMailer::Base

  def send_message(order_number, subject, message, from, to)
    @order_number = order_number
    subject = Illbackend::Application.config.email_settings[:subject_prefix] + subject
    @message = message
    mail(
      from: from,
      to: to,
      subject: subject
    )
  end

  def send_message_with_tokens(order, subject_template, message_template, from, to)
    @order_number = order.order_number
    subject = Illbackend::Application.config.email_settings[:subject_prefix] + token_replace(subject_template, order)
    @message = token_replace(message_template, order)
    mail(
      from: from,
      to: to,
      subject: subject,
      template_name: 'send_message'
    )
  end


  def confirmation(order)
    @order = order
    @managing_group = order.managing_group
    set_locale order.form_lang ? order.form_lang.to_sym : :sv
    mail(from:    @managing_group.email,
         to:      order.email_address,
         subject: Illbackend::Application.config.email_settings[:subject_prefix] + I18n.t('email.confirmation.subject') + order.order_number)
    set_default_locale
  end

private

  def lookup_attribute(record, path)
    *relationships, attribute = path.split(/\./)
    for relationship in relationships
      relationships = record.class.reflect_on_all_associations(:belongs_to).map(&:name)
      return nil unless relationships.include?(relationship.to_sym)
      record = record.send(relationship)
      return nil unless record.present?
    end
    return record.send(attribute) if record.attribute_names.include?(attribute)
  end

  def token_replace(template, record)
    template.gsub(/(\n)?\[(?:"([^"]+)")?\s*([\w.]+)\s*(?:"([^"]+)")?\]/m) do |match|
      token_value = lookup_attribute(record, $3)
      token_value.present? ? "#{$1}#{$2}#{token_value}#{$4}" : ""
    end
  end

  def set_locale locale
    I18n.locale = locale || I18n.default_locale
  end

  def set_default_locale
    I18n.locale = I18n.default_locale
  end
end

