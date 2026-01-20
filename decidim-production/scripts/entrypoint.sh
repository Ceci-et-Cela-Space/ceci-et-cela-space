#!/bin/sh
set -e

# Add French locale to Decidim
sed -i 's/config.available_locales = \[:en, :ca, :es\]/config.available_locales = [:en, :ca, :es, :fr]/' /code/config/initializers/decidim.rb

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL..."
until PGPASSWORD=$DATABASE_PASSWORD psql -h "$DATABASE_HOST" -U "$DATABASE_USERNAME" -d "$DATABASE_NAME" -c '\q' 2>/dev/null; do
  sleep 2
done
echo "PostgreSQL is ready!"

# Run database migrations
echo "Running database migrations..."
bundle exec rake db:migrate

# Precompile assets if needed
if [ ! -d "/code/public/assets" ] || [ -z "$(ls -A /code/public/assets 2>/dev/null)" ]; then
  echo "Precompiling assets..."
  bundle exec rake assets:precompile
fi

exec "$@"
