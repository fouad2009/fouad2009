class AutoCommentJob < ActiveJob::Base
  queue_as :default

  def perform
    to_email = 'Tarik.TOUDERT@algerietelecom.dz'

    begin
      smtp = ActionMailer::Base.smtp_settings

      # Convertir :none → nil car la gem Mail ne supporte pas :none
      auth = smtp[:authentication]
      auth = nil if auth == :none

      mail = Mail.new do
        from    'project_do@at.dz'
        to      to_email
        subject 'Test envoi mail concluant'
        body    "Salam,la fonctionalitée d'authentification via l'application est opérationnel#{Time.now}"
      end

      # Configurer l'envoi SMTP EN SE BASANT SUR LA CONFIG REDMINE
      mail.delivery_method :smtp,
        address:              smtp[:address],
        port:                 smtp[:port],
        domain:               smtp[:domain],
        authentication:       auth,                     # <= clé !
        enable_starttls_auto: smtp[:enable_starttls_auto],
        openssl_verify_mode:  smtp[:openssl_verify_mode]

      # Envoyer le mail
      mail.deliver!

      Rails.logger.info "Email envoyé avec succès à #{to_email}"

    rescue => e
      Rails.logger.error "Erreur d'envoi email : #{e.message}\n#{e.backtrace.join("\n")}"
    end
  end
end


