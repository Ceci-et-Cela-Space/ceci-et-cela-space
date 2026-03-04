#!/bin/sh
set -e

echo "Attente de PostgreSQL..."
until bundle exec rails runner "ActiveRecord::Base.connection.execute('SELECT 1')" 2>/dev/null; do
  sleep 2
done
echo "PostgreSQL prêt."

echo "Marquage des migrations Rails framework conflictuelles..."
bundle exec rails runner "
  # Tables créées par le générateur Decidim avant les migrations
  framework_tables = %w[
    active_storage_blobs active_storage_attachments active_storage_variant_records
    action_mailbox_inbound_emails action_text_rich_texts
  ]
  Dir['db/migrate/*.rb'].sort.each do |f|
    version = File.basename(f).match(/^\d+/)[0]
    next if ActiveRecord::SchemaMigration.where(version: version).exists?
    content = File.read(f)
    # Marquer si la migration crée une table déjà existante
    framework_tables.each do |table|
      if content.include?(table) && ActiveRecord::Base.connection.table_exists?(table)
        ActiveRecord::SchemaMigration.create!(version: version)
        puts \"Marqué : #{File.basename(f)}\"
        break
      end
    end
  end
"

echo "Lancement des migrations..."
bundle exec rake db:migrate

echo "Lancement du seed..."
bundle exec rake db:seed

echo "Démarrage de Puma..."
exec bundle exec puma -b tcp://0.0.0.0:3000
