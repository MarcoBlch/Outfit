#!/bin/bash
echo "Connecting to Railway and executing fix..."
railway ssh --command "cd /rails && bundle exec rake db:fix_id_defaults RAILS_ENV=production"
