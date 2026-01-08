class EnablePgvectorExtension < ActiveRecord::Migration[7.1]
  def up
    # DISABLED: pgvector extension not available on Railway standard PostgreSQL
    # To enable pgvector: deploy Railway's pgvector PostgreSQL template
    # https://railway.com/deploy/pgvector-latest
    #
    # Uncomment below when using PostgreSQL with pgvector support:
    # execute "CREATE EXTENSION IF NOT EXISTS vector"

    Rails.logger.info "Skipping pgvector extension (not available on standard PostgreSQL)"
  end

  def down
    # execute "DROP EXTENSION IF EXISTS vector"
  end
end
