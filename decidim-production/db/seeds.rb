# frozen_string_literal: true

# Crée l'admin système s'il n'existe pas
if Decidim::System::Admin.count.zero?
  email    = ENV.fetch("SYSTEM_ADMIN_EMAIL", "admin@#{ENV.fetch("DECIDIM_HOST", "localhost")}")
  password = ENV.fetch("SYSTEM_ADMIN_PASSWORD") do
    SecureRandom.hex(16).tap { |p| puts "ATTENTION - Mot de passe admin généré : #{p}" }
  end

  Decidim::System::Admin.create!(
    email: email,
    password: password,
    password_confirmation: password
  )
  puts "Admin système créé : #{email}"
end

# Crée l'organisation si elle n'existe pas
if Decidim::Organization.count.zero?
  host   = ENV.fetch("DECIDIM_HOST", "localhost")
  name   = ENV.fetch("DECIDIM_NAME", "Mon Decidim")
  locale = ENV.fetch("DECIDIM_DEFAULT_LOCALE", "fr")

  Decidim::Organization.create!(
    name: name,
    host: host,
    default_locale: locale,
    available_locales: ENV.fetch("DECIDIM_AVAILABLE_LOCALES", locale).split(","),
    reference_prefix: ENV.fetch("DECIDIM_REFERENCE_PREFIX", "DEC"),
    users_registration_mode: :enabled
  )
  puts "Organisation créée : #{name} (#{host})"
end
