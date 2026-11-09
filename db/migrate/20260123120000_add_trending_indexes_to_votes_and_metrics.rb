class AddTrendingIndexesToVotesAndMetrics < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    %w[index_blueprint_votes_on_created_at_and_votable_id index_usage_metrics_on_last_used_at_and_blueprint_id].each do |name|
      invalid = select_value(<<~SQL.squish)
        SELECT NOT i.indisvalid FROM pg_index i
        JOIN pg_class c ON c.oid = i.indexrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = current_schema() AND c.relname = #{connection.quote(name)}
      SQL
      execute "DROP INDEX CONCURRENTLY #{connection.quote_table_name(name)}" if invalid
    end
    add_index :votes, [:created_at, :votable_id], where: "votable_type = 'Blueprint'",
              name: "index_blueprint_votes_on_created_at_and_votable_id", algorithm: :concurrently, if_not_exists: true
    add_index :blueprint_usage_metrics, [:last_used_at, :blueprint_id],
              name: "index_usage_metrics_on_last_used_at_and_blueprint_id", algorithm: :concurrently, if_not_exists: true
  end

  def down
    remove_index :votes, name: "index_blueprint_votes_on_created_at_and_votable_id", algorithm: :concurrently, if_exists: true
    remove_index :blueprint_usage_metrics, name: "index_usage_metrics_on_last_used_at_and_blueprint_id", algorithm: :concurrently, if_exists: true
  end
end
