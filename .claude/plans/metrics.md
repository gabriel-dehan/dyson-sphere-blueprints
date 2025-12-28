 Memory Optimization Plan - DSP Blueprints (512 MB Dyno)

 Executive Summary

 Problem: Heroku web dyno exceeds 512 MB quota with 5,374 R14 memory errors in 7 days
 - Peak memory: 142.9% (614.5 MB)
 - Average memory: 92.7% (474.6 MB)
 - Current config: 2 workers × 5 threads = 10 concurrent requests

 Goal: Reduce memory usage to stay under 512 MB without upgrading dyno type

 Strategy: Phased approach with quick wins first, then critical fixes, then optimizations

 ---
 Phase 1: Configuration Changes & Quick Wins (Low Risk, Immediate Impact)

 Estimated Memory Reduction: 30-40% (150-200 MB)
 Risk Level: LOW
 Deployment: Can deploy independently

 1.1 Reduce Puma Thread Count

 File: config/puma.rb

 Current Configuration:
 max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
 min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
 threads min_threads_count, max_threads_count
 workers Integer(ENV["WEB_CONCURRENCY"] || 2)

 Issue: Configured for 10 threads (2 workers × 5 threads) but only using 1.2 threads on average (12.42% utilization)

 Fix: Set environment variables on Heroku
 heroku config:set RAILS_MAX_THREADS=2
 heroku config:set RAILS_MIN_THREADS=2
 heroku config:set WEB_CONCURRENCY=2

 Impact: Reduces from 10 concurrent connections to 4, saving ~20-25% memory

 ---
 1.2 Enable Ruby YJIT

 Current: Not enabled
 Fix: Set environment variable on Heroku
 heroku config:set RUBY_YJIT_ENABLE=1

 Impact: 10-20% memory reduction with faster execution (Ruby 3.2+ feature)

 Requirements: Verify Ruby version is 3.2+ (currently using 3.2.5)

 ---
 1.3 Add GC Tuning for Constrained Environments

 File: config/boot.rb or Heroku environment variables

 Fix: Add Ruby GC environment variables optimized for 512 MB dyno
 heroku config:set RUBY_GC_HEAP_INIT_SLOTS=10000
 heroku config:set RUBY_GC_HEAP_FREE_SLOTS=2000
 heroku config:set RUBY_GC_HEAP_GROWTH_FACTOR=1.1
 heroku config:set RUBY_GC_HEAP_GROWTH_MAX_SLOTS=10000
 heroku config:set MALLOC_ARENA_MAX=2

 Impact: More aggressive garbage collection, reduces memory bloat

 ---
 1.4 Cache Mods in Memory Instead of Loading Every Request

 File: app/controllers/application_controller.rb (lines 22-24)

 Current:
 def set_mods
   @mods = Mod.all.order(created_at: :desc)
 end

 Issue: Loads all mods on EVERY request via before_action :set_mods

 Fix: Add caching with 1-hour TTL
 def set_mods
   @mods = Rails.cache.fetch("mods_list", expires_in: 1.hour) do
     Mod.all.order(created_at: :desc).to_a
   end
 end

 Impact: Eliminates 1 database query per request, reduces object allocation

 ---
 Phase 2: Critical Code Fixes (Medium Risk, High Impact)

 Estimated Memory Reduction: 40-50% (200-250 MB)
 Risk Level: MEDIUM
 Deployment: Requires testing before deployment

 2.1 CRITICAL: Move Blueprint Parsing to Background Jobs

 Files:
 - app/models/blueprint/factory.rb (line 25)
 - app/models/blueprint/dyson_sphere.rb (line 25)

 Current:
 def decode_blueprint
   BlueprintParserJob.perform_now(id) if saved_change_to_attribute?(:encoded_blueprint)
 end

 Issue: perform_now runs parsing synchronously in web request, blocking HTTP response and consuming web dyno memory

 Fix: Change to asynchronous
 def decode_blueprint
   BlueprintParserJob.perform_later(id) if saved_change_to_attribute?(:encoded_blueprint)
 end

 Impact:
 - Large blueprint parsing (700KB+) moves to Sidekiq worker
 - Reduces web dyno memory spikes by 50-100 MB per request
 - UX Change: Users will see "Processing..." state for a few seconds after upload

 Additional Changes Needed:
 - Add polling mechanism in frontend to check parsing status
 - Update UI to show "Blueprint parsing in progress..." message
 - Add parsed_at timestamp to blueprints table to track completion

 Note: Mecha blueprints already use perform_later for color extraction (line 28) - should follow same pattern

 ---
 2.2 CRITICAL: Remove Eager Loading from Default Scope

 File: app/models/blueprint.rb (line 23)

 Current:
 default_scope { includes(:mod, :tags, :tag_taggings, :user).where(mod: { name: "Dyson Sphere Program" }) }

 Issue:
 - Every Blueprint query loads :mod, :tags, :tag_taggings, :user even when not needed
 - For 32 blueprints per page, loads all tags/users/mods unnecessarily
 - Causes redundant eager loading in controllers that already use includes

 Fix: Remove eager loading, keep only the where clause
 default_scope { where(mod: { name: "Dyson Sphere Program" }) }

 Then: Add includes only where needed in controllers:
 - blueprints_controller.rb line 33 - Keep existing includes(:collection, collection: :user)
 - Add :tags where tags are displayed
 - Add :user where user info is shown

 Impact: Reduces memory by 30-50 MB per page load (depends on tag count)

 ---
 2.3 CRITICAL: Use light_query in All Listing Endpoints

 Files to Fix:
 1. app/controllers/users_controller.rb (lines 9-14)
 2. app/controllers/blueprints_controller.rb (line 49 - like action)
 3. app/controllers/blueprints_controller.rb (line 57 - unlike action)
 4. app/controllers/collections_controller.rb (line 90 - bulk_download)

 Current Example (users_controller.rb):
 def blueprints
   @user = User.find(params[:user_id])
   @blueprints = @user.blueprints
     .joins(:collection)
     .where(collection: { type: "Public" })
     .includes(:collection, collection: :user)
     .order(cached_votes_total: :desc)
     .page(params[:page])
 end

 Fix: Add .light_query to exclude encoded_blueprint column
 def blueprints
   @user = User.find(params[:user_id])
   @blueprints = @user.blueprints.light_query
     .joins(:collection)
     .where(collection: { type: "Public" })
     .includes(:collection, collection: :user)
     .order(cached_votes_total: :desc)
     .page(params[:page])
 end

 Impact:
 - Each blueprint's encoded_blueprint can be 700KB
 - For 32 blueprints per page: 700KB × 32 = 22.4 MB saved per request
 - Critical for like/unlike actions which don't need blueprint data at all

 Special Case - bulk_download:
 - Still needs encoded_blueprint but should load in batches
 - Use find_each instead of each to batch load

 ---
 2.4 CRITICAL: Stream Bulk Downloads Instead of Loading All into Memory

 File: app/controllers/collections_controller.rb (lines 76-119)

 Current:
 def bulk_download
   # Creates temp file
   @collection.blueprints.each do |blueprint|
     data = blueprint.encoded_blueprint  # Loads all blueprints into memory
     io.write(data)
   end
   zip_data = File.read(temp_file.path)  # Entire zip loaded into memory!
   send_data(zip_data, type: "application/zip", ...)
 end

 Issues:
 1. Uses .each which loads all blueprints at once
 2. Loads full zip file into memory before sending
 3. For collections with 100 blueprints × 700KB = 70 MB+

 Fix: Use batched loading and streaming
 def bulk_download
   # Use find_each for batch loading
   @collection.blueprints.find_each(batch_size: 10) do |blueprint|
     # ... existing code
   end

   # Stream file instead of loading into memory
   send_file temp_file.path,
     type: "application/zip",
     disposition: "attachment",
     filename: "#{@collection.title.parameterize}.zip"
   # Clean up temp file after sending
 end

 Impact: Reduces peak memory by 50-100 MB for large collections

 ---
 2.5 Fix Collections Index N+1 Query

 File: app/controllers/collections_controller.rb (lines 6-16)

 Current:
 def index
   @collections = policy_scope(Collection)
     .includes(:user)
     .joins(:blueprints)
     .where(type: "Public")
     .where.not(blueprints: { id: nil })
     .where(blueprints: { mod_id: @mods.first.id })
     .group("collections.id")
     .order("sum(blueprints.cached_votes_total) DESC")
     .page(params[:page])
 end

 Issues:
 - Joins blueprints but doesn't eager load them
 - When views call @collection.blueprints, triggers N queries
 - total_votes method (collection.rb:16-18) queries database for each collection

 Fix: Add blueprint counts and vote totals to query
 def index
   @collections = policy_scope(Collection)
     .includes(:user)
     .joins(:blueprints)
     .where(type: "Public")
     .where.not(blueprints: { id: nil })
     .where(blueprints: { mod_id: @mods.first.id })
     .group("collections.id")
     .select("collections.*, COUNT(blueprints.id) as blueprints_count, SUM(blueprints.cached_votes_total) as total_votes_sum")
     .order("total_votes_sum DESC")
     .page(params[:page])
 end

 Then in views: Use @collection.total_votes_sum instead of @collection.total_votes

 Impact: Eliminates 20+ queries per page load

 ---
 Phase 3: Optimization Improvements (Low Risk, Incremental Impact)

 Estimated Memory Reduction: 10-20% (50-100 MB)
 Risk Level: LOW
 Deployment: Can be deployed incrementally

 3.1 Replace Array Iteration with Database Queries for Mod Lookup

 Files:
 - app/controllers/concerns/blueprints_filters.rb (line 21)
 - app/controllers/blueprint/dyson_spheres_controller.rb (line 23)
 - app/controllers/blueprint/mechas_controller.rb (line 25)
 - app/controllers/blueprint/factories_controller.rb (line 21)
 - app/helpers/mods_helper.rb (lines 10, 27)

 Current:
 @filter_mod = @mods.find { |mod| mod.id == @filters[:mod_id].to_i }

 Issue: Loads all mods into array, then iterates to find one (O(n) operation)

 Fix: Use database query
 @filter_mod = Mod.find_by(id: @filters[:mod_id])
 # Or if @mods is cached:
 @filter_mod = @mods.detect { |mod| mod.id == @filters[:mod_id].to_i }

 Impact: Minor performance improvement, clearer code

 ---
 3.2 Remove Redundant Eager Loading in Blueprints Controller

 File: app/controllers/blueprints_controller.rb (line 33)

 Current:
 general_scope = policy_scope(Blueprint.light_query)
   .joins(:collection)
   .where(collection: { type: "Public" })
 # ...
 @blueprints = filter(general_scope.includes(:collection, collection: :user))

 Issue:
 - :collection is already joined (line 24), then eager loaded again (line 33)
 - Default scope includes :user, so it's loaded twice

 Fix: Only include what's not already loaded
 # After removing eager loading from default_scope
 @blueprints = filter(general_scope.includes(:collection, :user, :tags))

 Impact: Eliminates duplicate association loading

 ---
 3.3 Optimize Color Filter Query

 File: app/controllers/concerns/blueprints_filters.rb (lines 108-116)

 Current:
 def colors_by_hsl(searched_color, similarity)
   Color.includes(:blueprint_mecha_colors).where(...)
 end

 blueprint_ids = colors_by_hsl(@filters[:color], @filters[:color_similarity])
   .joins(:blueprint_mecha_colors)
   .select("blueprint_mecha_colors.blueprint_id")

 Issue: Includes blueprint_mecha_colors then immediately joins them - redundant

 Fix: Remove includes, use direct join
 def colors_by_hsl(searched_color, similarity)
   Color.where(...) # Remove includes
 end

 Impact: Minor query optimization

 ---
 3.4 Add Counter Cache for Blueprint Usage Metrics

 File: app/models/blueprint_usage_metric.rb (lines 15-20)

 Current:
 def update_blueprint_tally
   if saved_change_to_attribute?(:count)
     blueprint.usage_count += 1
     blueprint.save!
   end
 end

 Issue: Each metric save triggers blueprint save - extra query and object load

 Fix: Use Rails counter_cache
 # In migration:
 add_column :blueprints, :usage_metrics_count, :integer, default: 0

 # In model:
 belongs_to :blueprint, counter_cache: :usage_metrics_count

 # Remove update_blueprint_tally callback

 Impact: Eliminates extra save operation per metric update

 ---
 3.5 Add Database Indexes for Common Queries

 File: Create new migration

 Missing Indexes:
 1. collections(created_at) - used in filtering
 2. blueprints(collection_id, cached_votes_total) - compound index for collections index query
 3. blueprint_mecha_colors(blueprint_id, color_id) - compound index for color filtering

 Migration:
 class AddMemoryOptimizationIndexes < ActiveRecord::Migration[6.1]
   def change
     add_index :collections, :created_at
     add_index :blueprints, [:collection_id, :cached_votes_total]
     add_index :blueprint_mecha_colors, [:blueprint_id, :color_id],
               name: 'index_mecha_colors_on_blueprint_and_color'
   end
 end

 Impact: Faster queries, less database overhead

 ---
 3.6 Add Blueprint Parsing Status UI

 Files:
 - Create migration for parsed_at timestamp
 - Update frontend JavaScript to poll status
 - Add controller action to check parsing status

 Migration:
 class AddParsedAtToBlueprints < ActiveRecord::Migration[6.1]
   def change
     add_column :blueprints, :parsed_at, :datetime
     add_index :blueprints, :parsed_at
   end
 end

 Controller (new action):
 def parsing_status
   @blueprint = Blueprint.find(params[:id])
   render json: {
     parsed: @blueprint.parsed_at.present?,
     summary: @blueprint.summary
   }
 end

 Frontend: Add polling in Stimulus controller to check status every 2 seconds

 Impact: Enables async parsing without confusing users

 ---
 Phase 4: Monitoring & Validation

 4.1 Add Memory Profiling to Production (Temporary)

 Purpose: Verify fixes are working

 Tools:
 - Barnes (already installed) - monitor per-worker memory
 - Add Skylight or AppSignal for request-level memory tracking

 4.2 Enable Bullet in Staging

 File: config/environments/staging.rb

 Add:
 config.after_initialize do
   Bullet.enable = true
   Bullet.rails_logger = true
   Bullet.add_footer = true
 end

 Purpose: Catch N+1 queries before production deployment

 ---
 Complete File List for Changes

 Phase 1 (Config):

 - Heroku environment variables (no file changes)
 - config/boot.rb (optional - for GC tuning)
 - app/controllers/application_controller.rb (mod caching)

 Phase 2 (Critical):

 - app/models/blueprint/factory.rb
 - app/models/blueprint/dyson_sphere.rb
 - app/models/blueprint.rb
 - app/controllers/users_controller.rb
 - app/controllers/blueprints_controller.rb
 - app/controllers/collections_controller.rb

 Phase 3 (Optimization):

 - app/controllers/concerns/blueprints_filters.rb
 - app/controllers/blueprint/dyson_spheres_controller.rb
 - app/controllers/blueprint/mechas_controller.rb
 - app/controllers/blueprint/factories_controller.rb
 - app/helpers/mods_helper.rb
 - app/models/blueprint_usage_metric.rb
 - New migration for indexes
 - New migration for parsed_at column
 - Frontend JavaScript for polling (blueprint parser controllers)

 ---
 Implementation Order

 1. Deploy Phase 1 (Config changes) - can be done immediately via Heroku CLI
 2. Develop Phase 2 (Critical fixes) - test in staging, requires code changes
 3. Monitor for 24 hours - verify memory reduction
 4. Deploy Phase 3 (Optimizations) - incremental improvements
 5. Monitor for 7 days - validate fixes hold under load

 ---
 Expected Results

 | Phase    | Memory Reduction | R14 Errors | Notes             |
 |----------|------------------|------------|-------------------|
 | Baseline | 0%               | 5,374/week | Current state     |
 | Phase 1  | 30-40%           | <100/week  | Config only, safe |
 | Phase 2  | 70-80%           | 0/week     | Critical fixes    |
 | Phase 3  | 80-90%           | 0/week     | Full optimization |

 Target: Stay under 450 MB average (87% of 512 MB quota) with headroom for traffic spikes

 ---
 Risks & Mitigation

 Risk 1: Async Blueprint Parsing Changes UX

 - Mitigation: Add clear "Processing..." UI with polling
 - Fallback: Keep mecha synchronous (smaller files), only async for Factory/DysonSphere

 Risk 2: Removing Default Scope Breaks Existing Queries

 - Mitigation: Thoroughly test all blueprint listing pages
 - Fallback: Add includes to each controller individually

 Risk 3: Thread Reduction Causes Request Queueing

 - Mitigation: Monitor response times and queue depth
 - Fallback: Increase back to 3 threads (middle ground)

 ---
 Testing Checklist

 - Blueprint upload and parsing (Factory, DysonSphere, Mecha)
 - Blueprint listing pages (index, user blueprints, collection blueprints)
 - Collection bulk download
 - Blueprint like/unlike actions
 - Tag filtering
 - Color filtering (mecha)
 - Mod version filtering
 - Search functionality
 - Load test with 32 concurrent requests (simulate 2 workers × 2 threads × 8 = capacity)

 ---
 Additional Findings Not Addressed (Future Work)

 These issues were identified but are lower priority or need more investigation:

 1. Image Processing Memory: Mecha PNG generation (lib/parsers/mecha_blueprint.rb:17-26) loads images into memory but has proper cleanup
 2. Large Blueprint Show Page: Shows full encoded_blueprint in textarea even for large files (>700KB), but this is expected behavior
 3. Mod Version Compatibility Calculation: Mod#compatibility_range_for is complex but not called frequently
 4. Tag Filtering: Works but could be optimized with better caching
 5. Shrine Image Processing: Uses libvips which is memory-efficient already

 ---
 Notes

 - Do NOT run rails commands on Heroku production (per CLAUDE.md instructions)
 - All database migrations should be tested locally first
 - Sidekiq worker dyno should be running (separate from web dyno)
 - Barnes and PumaWorkerKiller are already configured correctly
 - light_query scope exists and works well - just needs wider adoption
