class AddTrendingIndexesToVotesAndMetrics < ActiveRecord::Migration[6.1]
  def change
    # Index for votes query in trending calculation
    # Supports: WHERE votable_type = 'Blueprint' AND votable_id = X AND created_at >= Y
    add_index :votes, [:votable_type, :votable_id, :created_at],
              name: "index_votes_on_votable_and_created_at"
    # Index for blueprint_usage_metrics query in trending calculation
    # Supports: WHERE blueprint_id = X AND last_used_at >= Y
    add_index :blueprint_usage_metrics, [:blueprint_id, :last_used_at],
              name: "index_blueprint_usage_metrics_on_blueprint_and_last_used"
  end
end
