Heroku Metrics Analysis Report

🚨 Critical Issues

1. Memory Quota Exceeded (R14 Errors)

- 5,374 memory errors in the past 7 days
- Latest memory usage: 120.0% of quota (exceeding limit)
- Peak memory usage: 142.9% (614.5 MB) against 512 MB quota
- Average usage: 92.7% (474.6 MB) - consistently near limit
- Multiple R14 restarts visible in the Events timeline

Impact: Your dynos are being killed and restarted when they exceed 512 MB, causing:
- Request failures during restart
- User-facing errors
- Poor application performance
- Potential data loss from interrupted requests

2. Memory Metrics Inconsistency

The "stretched" metrics you noticed:
- MAX: 142.9% (614.5 MB)
- AVG: 92.7% (731.7 MB) ← This shows 731.7 MB average but only 614.5 MB max, which is mathematically impossible

This suggests either:
- A display bug in Heroku metrics
- Different measurement windows for different stats
- The metrics are combining data from multiple dynos inconsistently

📊 Performance Metrics (Generally Healthy)

Response Times

- Median (50th percentile): 91 ms - Good
- 95th percentile: 151 ms - Acceptable
- 99th percentile: 231 ms - Reasonable
- Occasional spikes to 5,119 ms - Likely during R14 restarts

Throughput

- ~4 requests/second average
- 28k successful requests (2XX) over 7 days
- Zero 5XX errors - Good application stability when running
- 239 4XX errors - Minimal client errors

Dyno Load

- Average load: 0.14 - Very low CPU usage
- Max load: 0.64 - Still well below capacity
- CPU is not the bottleneck

🔍 Ruby-Specific Metrics

Heap Objects (Beta)

- ~1.85 million objects allocated at peak
- ~1.85 million objects freed (good garbage collection)
- Net: ~79 objects difference (avg alloc - avg freed = 115,332 - 115,253)
- GC is working but total memory footprint is still too large

Puma Pool Usage

- 10 threads spawned (100% of pool)
- Average usage: 12.42% (1.2 threads active)
- Max usage: 60% (6 threads)
- Thread pool is appropriately sized; not the issue

Free Memory Slots

- Average: 1,267 slots
- Minimum: 80 slots - Concerning when combined with high memory
- When slots drop low + memory is high = GC pressure

🎯 Root Cause Analysis

Your Rails app's memory footprint is too large for a 512 MB dyno. Common causes:

1. Large object allocations (blueprints, parsed data)
2. Memory leaks in long-running processes
3. Inadequate garbage collection tuning
4. Too many Puma workers/threads for dyno size
5. Large gem dependencies or Rails overhead
6. N+1 queries loading excessive ActiveRecord objects
7. Image processing or file handling in-memory

✅ Recommended Solutions

Immediate (Choose One)

1. Upgrade dyno type to Standard-1X (1 GB) or Standard-2X (2 GB)
  - Quickest fix
  - Costs more but solves immediate crisis
2. Reduce Puma configuration
  - Currently spawning 10 threads but only using ~1.2 on average
  - Try reducing from threads 5, 5 to threads 2, 2
  - Or reduce workers if using clustered mode

Short-term

3. Enable Ruby 3.x YJIT (if on Ruby 3.1+)
  - Can reduce memory by 10-20%
  - Set RUBY_YJIT_ENABLE=1
4. Optimize ActiveRecord queries
  - Look for N+1 queries loading blueprints
  - Use includes/joins appropriately
  - Leverage light_query scope you have
5. Review blueprint parsing
  - Large blueprints (>700KB) should be processed in background jobs
  - Ensure BlueprintParserJob isn't running in web dyno

Long-term

6. Add memory profiling
  - Use memory_profiler or derailed_benchmarks gems
  - Identify specific memory hogs
  - Profile endpoints causing R14 errors
7. Implement caching
  - Cache parsed blueprint data
  - Use Redis for frequently accessed data
  - Add HTTP caching headers
8. Optimize gem bundle
  - Audit Gemfile for unnecessary gems
  - Check gem memory footprints
