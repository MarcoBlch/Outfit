class FixAllIdSequenceDefaults < ActiveRecord::Migration[7.1]
  # This migration fixes a critical issue where id columns with sequences
  # are missing DEFAULT nextval() clauses, causing "null value in column id"
  # errors when inserting records.
  #
  # Context: The Railway database is missing DEFAULT clauses on all id columns,
  # even though sequences exist and are properly owned by the columns.
  # This happens when databases are restored from dumps that don't preserve
  # the ALTER TABLE ... SET DEFAULT statements.

  def up
    # Fix all tables that have bigint id columns with sequences
    fix_id_default('active_storage_attachments', 'active_storage_attachments_id_seq')
    fix_id_default('active_storage_blobs', 'active_storage_blobs_id_seq')
    fix_id_default('active_storage_variant_records', 'active_storage_variant_records_id_seq')
    fix_id_default('ad_impressions', 'ad_impressions_id_seq')
    fix_id_default('outfit_items', 'outfit_items_id_seq')
    fix_id_default('outfit_suggestions', 'outfit_suggestions_id_seq')
    fix_id_default('outfits', 'outfits_id_seq')
    fix_id_default('product_recommendations', 'product_recommendations_id_seq')
    fix_id_default('subscriptions', 'subscriptions_id_seq')
    fix_id_default('user_profiles', 'user_profiles_id_seq')
    fix_id_default('users', 'users_id_seq')
    fix_id_default('wardrobe_items', 'wardrobe_items_id_seq')
  end

  def down
    # Remove defaults if rolling back (though this would break inserts)
    remove_id_default('active_storage_attachments')
    remove_id_default('active_storage_blobs')
    remove_id_default('active_storage_variant_records')
    remove_id_default('ad_impressions')
    remove_id_default('outfit_items')
    remove_id_default('outfit_suggestions')
    remove_id_default('outfits')
    remove_id_default('product_recommendations')
    remove_id_default('subscriptions')
    remove_id_default('user_profiles')
    remove_id_default('users')
    remove_id_default('wardrobe_items')
  end

  private

  def fix_id_default(table_name, sequence_name)
    execute <<-SQL.squish
      ALTER TABLE #{table_name}
      ALTER COLUMN id
      SET DEFAULT nextval('#{sequence_name}'::regclass);
    SQL

    say "Fixed id default for #{table_name} to use #{sequence_name}", true
  end

  def remove_id_default(table_name)
    execute <<-SQL.squish
      ALTER TABLE #{table_name}
      ALTER COLUMN id
      DROP DEFAULT;
    SQL

    say "Removed id default for #{table_name}", true
  end
end
