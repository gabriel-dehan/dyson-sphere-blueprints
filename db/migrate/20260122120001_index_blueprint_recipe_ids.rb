class IndexBlueprintRecipeIds < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    invalid = select_value(<<~SQL)
      SELECT NOT i.indisvalid FROM pg_index i
      JOIN pg_class c ON c.oid = i.indexrelid
      JOIN pg_namespace n ON n.oid = c.relnamespace
      WHERE n.nspname = current_schema() AND c.relname = 'index_blueprints_on_recipe_ids'
    SQL
    execute "DROP INDEX CONCURRENTLY index_blueprints_on_recipe_ids" if invalid
    add_index :blueprints, :recipe_ids, using: :gin, algorithm: :concurrently, if_not_exists: true
  end

  def down
    remove_index :blueprints, :recipe_ids, algorithm: :concurrently, if_exists: true
  end
end
