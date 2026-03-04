# frozen_string_literal: true

Decidim.configure do |config|
  config.application_name = Rails.application.secrets.decidim[:application_name]
  config.mailer_sender    = Rails.application.secrets.decidim[:mailer_sender]

  config.available_locales = Rails.application.secrets.decidim[:available_locales]
                               .to_s.split(",").map(&:strip)
  config.default_locale    = Rails.application.secrets.decidim[:default_locale]
  config.currency_unit     = Rails.application.secrets.decidim[:currency_unit]

  config.geocoder = {
    static_map_url: "https://www.openstreetmap.org/export/embed.html"
  }
end
