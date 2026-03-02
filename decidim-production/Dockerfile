FROM ruby:3.1.4-bullseye

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs npm imagemagick libvips && \
    npm install -g yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN gem install decidim -v 0.28.0

COPY Gemfile ./

# Patch de compatibilité Ruby/Rails
RUN ruby -e "require 'logger'"

# Génération de l'application SANS créer de sous-dossier (en utilisant le point .)
# S'il crée un dossier ceci_et_cela, on va forcer le déplacement des fichiers après.
RUN ruby -rlogger /usr/local/bundle/bin/decidim --path . ceci_et_cela

# LA SOLUTION EST ICI : on déplace tout le contenu du dossier ceci_et_cela vers /app
# et on supprime le dossier vide.
RUN mv ceci_et_cela/* . && mv ceci_et_cela/.[!.]* . && rmdir ceci_et_cela

# On écrase le Gemfile généré par Decidim avec le tien
COPY Gemfile ./

RUN bundle install

ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=dummy_key_for_build
RUN bundle exec rails assets:precompile

EXPOSE 3000
