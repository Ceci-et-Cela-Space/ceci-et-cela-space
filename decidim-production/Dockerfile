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
# On écrase le routes.rb généré avec le nôtre (contient le mount Decidim)
COPY config/routes.rb config/routes.rb

# Installation des paquets Ruby
RUN bundle install

# Copie des migrations des gems dans db/migrate/ (timestamps fixes dans l'image)
RUN bundle exec rake railties:install:migrations

# On définit l'environnement
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=dummy_key_for_build

# Installation de shakapacker
RUN bundle exec rails shakapacker:install

# Installation de webpacker spécifique à Decidim
RUN bundle exec rails decidim:webpacker:install

# Fix SCSS: ajouter node_modules aux additional_paths pour sass-embedded
# (decidim-sass-loader.js l'utilise comme loadPaths pour résoudre tailwindcss/tom-select)
RUN ruby -ryaml -e "f='config/shakapacker.yml';c=YAML.safe_load(File.read(f),aliases:true);c.each{|_,s|next unless s.is_a?(Hash);s['additional_paths']||=[];s['additional_paths']<<'node_modules' unless s['additional_paths'].include?('node_modules')};File.write(f,c.to_yaml)"

# yarn install + ajout explicite des peer dependencies non installées automatiquement
# (graphiql pour l'API, turbolinks et emojibase sont des peer deps de Decidim)
RUN yarn install --ignore-engines && \
    yarn add graphiql@1.4.7 turbolinks emojibase picmo --ignore-engines

# Symlink pour que webpack trouve node_modules en remontant depuis les entrypoints des gems
RUN ln -s /app/node_modules /usr/local/bundle/gems/node_modules

# Et on compile les assets finaux
RUN bundle exec rails assets:precompile

# Copie du seed et du script de démarrage
COPY db/seeds.rb db/seeds.rb
COPY scripts/start.sh scripts/start.sh
RUN chmod +x scripts/start.sh

EXPOSE 3000
