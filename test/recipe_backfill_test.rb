require "test_helper"
require "rake"

class RecipeBackfillTest < ActiveSupport::TestCase
  test "backfill is resumable and preserves updated timestamps" do
    blueprint = blueprints(:public_factory)
    blueprint.update!(summary: { buildings: { "1" => { recipes: { "5" => {}, "2" => {} } } } })
    blueprint.update_columns(recipe_ids: nil)
    timestamp = blueprint.reload.updated_at

    Rails.application.load_tasks unless Rake::Task.task_defined?("blueprint:backfill_recipe_ids")
    task = Rake::Task["blueprint:backfill_recipe_ids"]
    old_delay = ENV["BATCH_DELAY"]
    ENV["BATCH_DELAY"] = "0"
    capture_io { task.invoke }
    assert_equal [2, 5], blueprint.reload.recipe_ids
    assert_equal timestamp, blueprint.updated_at

    task.reenable
    capture_io { task.invoke }
    assert_equal [2, 5], blueprint.reload.recipe_ids
    assert_equal timestamp, blueprint.updated_at
  ensure
    ENV["BATCH_DELAY"] = old_delay
  end
end
