class AddRecipeIdsToBlueprints < ActiveRecord::Migration[6.1]
  def up
    # Store recipe ids alongside blueprints for fast filtering.
    add_column :blueprints, :recipe_ids, :integer, array: true, default: [], null: false
    # GIN index supports @> array containment queries.
    add_index :blueprints, :recipe_ids, using: :gin

    # Backfill recipe_ids from summary JSON (buildings -> recipes keys).
    execute <<~SQL.squish
      UPDATE blueprints
      SET recipe_ids = COALESCE(recipes.recipe_ids, '{}')
      FROM (
        SELECT b.id,
               ARRAY_AGG(DISTINCT recipe_key::int) AS recipe_ids
        FROM blueprints b
        LEFT JOIN LATERAL jsonb_each(COALESCE(b.summary::jsonb -> 'buildings', '{}'::jsonb)) AS building(entity_id, data) ON TRUE
        LEFT JOIN LATERAL jsonb_object_keys(COALESCE(building.data -> 'recipes', '{}'::jsonb)) AS recipe_key ON TRUE
        GROUP BY b.id
      ) AS recipes
      WHERE blueprints.id = recipes.id
    SQL
  end

  def down
    remove_index :blueprints, :recipe_ids
    remove_column :blueprints, :recipe_ids
  end
end
