FROM ruby:3.1.4-bullseye

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs npm imagemagick libvips && \
    npm install -g yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN gem install decidim -v 0.28.0

COPY Gemfile ./

RUN ruby -e "require 'logger'"
RUN ruby -rlogger /usr/local/bundle/bin/decidim --path . ceci_et_cela

RUN mv ceci_et_cela/* . && mv ceci_et_cela/.[!.]* . && rmdir ceci_et_cela

COPY Gemfile ./

RUN bundle install

# On définit l'environnement AVANT toutes les commandes Rails
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=dummy_key_for_build

# On installe shakapacker en forçant l'écrasement s'il pose une question
RUN RAILS_ENV=production bundle exec rails shakapacker:install

# Et on compile les assets
RUN bundle exec rails assets:precompile

EXPOSE 3000
