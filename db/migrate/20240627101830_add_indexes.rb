class AddIndexes < ActiveRecord::Migration[6.1]
  def up
    # Blueprints table
    add_index :blueprints, :created_at, order: { created_at: :desc }
    add_index :blueprints, :type
    add_index :blueprints, :mod_version
    add_index :blueprints, :cached_votes_total
    add_index :blueprints, :usage_count
    add_index :blueprints, "(summary ->> 'total_structures')", using: :btree

    # Tags table
    add_index :tags, "LOWER(name)"

    # Mods table
    add_index :mods, :name

    # Users table
    add_index :users, :role

    # Add trigram index for PostgreSQL (uncomment if using PostgreSQL)
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    execute "CREATE INDEX index_tags_on_name_trigram ON tags USING gin (name gin_trgm_ops);"
  end

  def down
    # Blueprints table
    remove_index :blueprints, column: :created_at, order: { created_at: :desc }
    remove_index :blueprints, column: :type
    remove_index :blueprints, :mod_version
    remove_index :blueprints, :cached_votes_total
    remove_index :blueprints, :usage_count
    remove_index :blueprints, name: "index_blueprints_on_summary_total_structures"

    # Tags table
    remove_index :tags, name: "index_tags_on_LOWER_name"

    # Mods table
    remove_index :mods, column: :name

    # Users table
    remove_index :users, column: :role

    # Remove trigram index for PostgreSQL (uncomment if using PostgreSQL)
    execute "DROP INDEX IF EXISTS index_tags_on_name_trigram;"
    execute "DROP EXTENSION IF EXISTS pg_trgm;"
  end
end
