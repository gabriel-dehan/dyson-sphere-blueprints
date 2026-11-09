class CreateBlueprintTrendingScores < ActiveRecord::Migration[6.1]
  def up
    # Refresh replaces the snapshot; a cascading foreign key can deadlock with blueprint deletion.
    create_table :blueprint_trending_scores, id: false do |t|
      t.bigint :blueprint_id, null: false, primary_key: true
      t.float :score, null: false
    end

    create_table :blueprint_trending_refreshes do |t|
      t.bigint :generation, null: false, default: 0
    end
    execute "INSERT INTO blueprint_trending_refreshes (id, generation) VALUES (1, 0)"
  end

  def down
    drop_table :blueprint_trending_scores
    drop_table :blueprint_trending_refreshes
  end
end
