class BlueprintTrendingScore < ApplicationRecord
  def self.refresh!
    connection.transaction(requires_new: true) do
      connection.execute("INSERT INTO blueprint_trending_refreshes (id, generation) VALUES (1, 0) ON CONFLICT (id) DO NOTHING")
      connection.execute("SELECT id FROM blueprint_trending_refreshes WHERE id = 1 FOR UPDATE")
      connection.execute("DELETE FROM blueprint_trending_scores")
      connection.execute(<<~SQL)
        INSERT INTO blueprint_trending_scores (blueprint_id, score)
        WITH recent_votes AS (
          SELECT votable_id, COUNT(*) AS count FROM votes
          WHERE votable_type = 'Blueprint' AND created_at >= CURRENT_TIMESTAMP - INTERVAL '7 days'
          GROUP BY votable_id
        ), recent_usage AS (
          SELECT blueprint_id, COUNT(DISTINCT user_id) AS count FROM blueprint_usage_metrics
          WHERE last_used_at >= CURRENT_TIMESTAMP - INTERVAL '7 days'
          GROUP BY blueprint_id
        )
        SELECT b.id,
          (COALESCE(v.count, 0) * 3.0 + COALESCE(u.count, 0) * 1.5 +
           COALESCE(b.cached_votes_total, 0) * 2.0 + COALESCE(b.usage_count, 0)) *
          CASE WHEN b.created_at >= CURRENT_TIMESTAMP - INTERVAL '7 days' THEN 1.3
               WHEN b.created_at >= CURRENT_TIMESTAMP - INTERVAL '30 days' THEN 1.15
               ELSE 1.0 END
        FROM blueprints b
        LEFT JOIN recent_votes v ON v.votable_id = b.id
        LEFT JOIN recent_usage u ON u.blueprint_id = b.id
      SQL
      connection.execute("UPDATE blueprint_trending_refreshes SET generation = generation + 1 WHERE id = 1")
    end
  end
end
