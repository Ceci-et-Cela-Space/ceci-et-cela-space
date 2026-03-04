#!/bin/sh
set -e

echo "Attente de PostgreSQL..."
until bundle exec rails runner "ActiveRecord::Base.connection.execute('SELECT 1')" 2>/dev/null; do
  sleep 2
done
echo "PostgreSQL prêt."

echo "Marquage des migrations ActiveStorage conflictuelles si les tables existent déjà..."
bundle exec rails runner "
  Dir['db/migrate/*active_storage*'].sort.each do |f|
    version = File.basename(f).match(/^\d+/)[0]
    next if ActiveRecord::SchemaMigration.where(version: version).exists?
    ActiveRecord::SchemaMigration.create!(version: version)
    puts \"Marqué comme appliqué : #{File.basename(f)}\"
  end
"

echo "Lancement des migrations..."
bundle exec rake db:migrate

echo "Lancement du seed..."
bundle exec rake db:seed

echo "Démarrage de Puma..."
exec bundle exec puma -b tcp://0.0.0.0:3000
