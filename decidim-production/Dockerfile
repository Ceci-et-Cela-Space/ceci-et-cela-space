FROM ruby:3.2.2-bullseye

# Installation des dépendances système
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs npm imagemagick libvips && \
    npm install -g yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Création du dossier de l'application
WORKDIR /app

# Installation de la commande de génération
RUN gem install decidim -v 0.28.0

# Copie de ton Gemfile personnalisé
COPY Gemfile ./

# Génération de la coquille Rails avec le nom de ta coopérative
RUN decidim --path . ceci_et_cela

# Installation finale des gems
RUN bundle install

# Compilation des assets (CSS/JS)
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=dummy_key_for_build
RUN bundle exec rails assets:precompile

EXPOSE 3000
CMD ["bash", "-c", "bundle exec rails db:migrate && bundle exec puma -C config/puma.rb"]
