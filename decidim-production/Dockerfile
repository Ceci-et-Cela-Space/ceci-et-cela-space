FROM ruby:3.1.4-bullseye

# Installation de Node.js 20 (LTS) - C'est LA clé du problème !
RUN apt-get update -qq && apt-get install -y curl gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

# Installation des dépendances système
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs imagemagick libvips && \
    npm install -g yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN gem install decidim -v 0.28.6

COPY Gemfile ./

# Patch de compatibilité
RUN ruby -e "require 'logger'"

# Génération de l'application
RUN ruby -rlogger /usr/local/bundle/bin/decidim --path . ceci_et_cela

# On déplace tout le contenu vers /app
RUN mv ceci_et_cela/* . && mv ceci_et_cela/.[!.]* . && rmdir ceci_et_cela

COPY Gemfile ./

# Installation des paquets Ruby
RUN bundle install

# On définit l'environnement
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=dummy_key_for_build

# Installation de shakapacker
RUN bundle exec rails shakapacker:install

# Installation de webpacker spécifique à Decidim
RUN bundle exec rails decidim:webpacker:install

# Installation de graphiql avec yarn install explicite pour s'assurer que node_modules existe
RUN yarn install && yarn add graphiql@1.4.7 --ignore-engines

# Et on compile les assets finaux
RUN bundle exec rails assets:precompile

EXPOSE 3000
