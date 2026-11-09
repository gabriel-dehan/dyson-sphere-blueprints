require "test_helper"
require "timeout"

class BlueprintTrendingConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test "readers see the old snapshot while overlapping refreshes serialize" do
    BlueprintTrendingScore.refresh!
    connection = ActiveRecord::Base.connection
    old_scores = BlueprintTrendingScore.order(:blueprint_id).pluck(:blueprint_id, :score)
    old_generation = Blueprint.trending_generation
    blueprints(:public_factory).update_columns(cached_votes_total: 999)
    paused = Queue.new
    resume = Queue.new
    second_pid = Queue.new
    subscription = ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, _start, _finish, _id, payload|
      if Thread.current[:pause_trending_refresh] && payload[:sql] == "DELETE FROM blueprint_trending_scores"
        paused << true
        resume.pop
      end
    end
    first = Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        Thread.current[:pause_trending_refresh] = true
        BlueprintTrendingScore.refresh!
      end
    end
    Timeout.timeout(10) { paused.pop }
    assert_equal old_scores, BlueprintTrendingScore.order(:blueprint_id).pluck(:blueprint_id, :score)
    assert_equal old_generation, Blueprint.trending_generation
    second = Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do |other_connection|
        second_pid << other_connection.select_value("SELECT pg_backend_pid()")
        BlueprintTrendingScore.refresh!
      end
    end
    pid = Timeout.timeout(10) { second_pid.pop }
    Timeout.timeout(10) do
      Thread.pass until connection.select_value("SELECT cardinality(pg_blocking_pids(#{Integer(pid)}))").to_i.positive?
    end
    resume << true
    first.value
    second.value
    assert_equal old_generation + 2, Blueprint.trending_generation
    assert_equal Blueprint.count, BlueprintTrendingScore.count
    assert_operator Blueprint.trending.find(blueprints(:public_factory).id).trending_score, :>, old_scores.to_h.fetch(blueprints(:public_factory).id)
  ensure
    resume << true if resume && first&.alive?
    first&.join
    second&.join
    ActiveSupport::Notifications.unsubscribe(subscription) if subscription
  end

  test "deleting a blueprint does not wait on a paused snapshot refresh" do
    connection = ActiveRecord::Base.connection
    source_id = blueprints(:public_factory).id
    id = connection.select_value(<<~SQL).to_i
      INSERT INTO blueprints (title, type, collection_id, game_version_id, game_version_string, created_at, updated_at)
      SELECT 'Concurrency test', type, collection_id, game_version_id, game_version_string, NOW(), NOW()
      FROM blueprints WHERE id = #{Integer(source_id)} RETURNING id
    SQL
    BlueprintTrendingScore.refresh!
    paused = Queue.new
    resume = Queue.new
    subscription = ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, _start, _finish, _id, payload|
      if Thread.current[:pause_trending_refresh] && payload[:sql] == "DELETE FROM blueprint_trending_scores"
        paused << true
        resume.pop
      end
    end
    refresh = Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        Thread.current[:pause_trending_refresh] = true
        BlueprintTrendingScore.refresh!
      end
    end
    Timeout.timeout(10) { paused.pop }
    deleted = Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do |db|
        db.execute("DELETE FROM blueprints WHERE id = #{Integer(id)}")
      end
    end
    assert Timeout.timeout(5) { deleted.value }
    resume << true
    refresh.value
    assert_not Blueprint.exists?(id)
    assert_not BlueprintTrendingScore.exists?(blueprint_id: id)
  ensure
    resume << true if resume && refresh&.alive?
    refresh&.join
    deleted&.join
    ActiveSupport::Notifications.unsubscribe(subscription) if subscription
  end
end
