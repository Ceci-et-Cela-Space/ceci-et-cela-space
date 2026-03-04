#!/bin/sh
set -e

echo "Attente de PostgreSQL..."
until bundle exec rails runner "ActiveRecord::Base.connection.execute('SELECT 1')" 2>/dev/null; do
  sleep 2
done
echo "PostgreSQL prêt."

echo "Correction migration active_storage_variant_records si nécessaire..."
bundle exec rails runner "
  pattern = Dir['db/migrate/*create_active_storage_variant_records*'].first
  if pattern
    version = File.basename(pattern).match(/^\d+/)[0]
    if ActiveRecord::Base.connection.table_exists?('active_storage_variant_records') && !ActiveRecord::SchemaMigration.where(version: version).exists?
      ActiveRecord::SchemaMigration.create!(version: version)
      puts 'Migration active_storage_variant_records marquée comme appliquée.'
    end
  end
"

echo "Lancement des migrations..."
bundle exec rake db:migrate

echo "Lancement du seed..."
bundle exec rake db:seed

echo "Démarrage de Puma..."
exec bundle exec puma -b tcp://0.0.0.0:3000
