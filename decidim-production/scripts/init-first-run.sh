#!/bin/sh
set -e

# This script should be run ONCE after the first deployment
# to create the database and admin user

# Add French locale
sed -i 's/config.available_locales = \[:en, :ca, :es\]/config.available_locales = [:en, :ca, :es, :fr]/' /code/config/initializers/decidim.rb

# Wait for PostgreSQL
echo "Waiting for PostgreSQL..."
until PGPASSWORD=$DATABASE_PASSWORD psql -h "$DATABASE_HOST" -U "$DATABASE_USERNAME" -d "$DATABASE_NAME" -c '\q' 2>/dev/null; do
  sleep 2
done

# Create database schema
echo "Creating database schema..."
bundle exec rake db:schema:load

# Create system admin
echo "Creating system admin..."
bundle exec rake decidim_system:create_admin

echo ""
echo "============================================"
echo "Initial setup complete!"
echo "============================================"
echo ""
echo "You can now:"
echo "1. Go to https://yourdomain.com/system"
echo "2. Log in with the admin credentials you just created"
echo "3. Create your organization"
echo ""
