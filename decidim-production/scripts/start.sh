#!/bin/sh
set -e

echo "Attente de PostgreSQL..."
until bundle exec rails runner "ActiveRecord::Base.connection.execute('SELECT 1')" 2>/dev/null; do
  sleep 2
done
echo "PostgreSQL prêt."

echo "Vérification de l'état de la base de données..."
bundle exec rails runner "
  if ActiveRecord::Base.connection.table_exists?('decidim_organizations')
    puts 'Base déjà initialisée : marquage de toutes les migrations comme appliquées.'
    Dir['db/migrate/*.rb'].sort.each do |f|
      version = File.basename(f).match(/^\d+/)[0]
      next if ActiveRecord::SchemaMigration.where(version: version).exists?
      ActiveRecord::SchemaMigration.create!(version: version)
    end
    puts 'Fait.'
  else
    puts 'Base vide : les migrations vont tourner normalement.'
  end
"

echo "Lancement des migrations..."
bundle exec rake db:migrate

echo "Lancement du seed..."
bundle exec rake db:seed

echo "Démarrage de Puma..."
exec bundle exec puma -b tcp://0.0.0.0:3000
