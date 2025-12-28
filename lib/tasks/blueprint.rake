namespace :blueprint do
  desc "Recompute all blueprint datas in batches (safe for production)" # Processes blueprints in batches to avoid overwhelming the queue
  task batch_fix_missing_data: :environment do
    batch_size = ENV.fetch("BATCH_SIZE", 100).to_i
    delay_between_batches = ENV.fetch("BATCH_DELAY", 2).to_i # seconds

    total_count = Blueprint.includes(:mod).where(mod: { name: "Dyson Sphere Program" }).where(summary: nil).count
    processed = 0

    puts "Starting batch recompute for #{total_count} blueprints..."
    puts "Batch size: #{batch_size}, Delay between batches: #{delay_between_batches}s"

    Blueprint.includes(:mod)
      .where(mod: { name: "Dyson Sphere Program" })
      .where(summary: nil)
      .find_in_batches(batch_size: batch_size) do |batch|
        batch.each { |blueprint| BlueprintParserJob.perform_later(blueprint.id) }
        processed += batch.size

        puts "Enqueued #{processed}/#{total_count} blueprints (#{(processed.to_f / total_count * 100).round(2)}%)"

        # Don't sleep after the last batch
        sleep delay_between_batches unless processed >= total_count
      end

    puts "Finished! Enqueued #{processed} jobs total."
  end

  desc "Recompute all blueprint datas" # Useful when new entities are added, entities names are changed, etc... Because the summary is computed only once
  task recompute_data: :environment do
    Blueprint.includes(:mod).where(mod: { name: "Dyson Sphere Program" }).each do |blueprint|
      BlueprintParserJob.perform_later(blueprint.id)
    end
  end

  task recompute_mechas: :environment do
    Blueprint::Mecha.includes(:mod).where(mod: { name: "Dyson Sphere Program" }).each do |blueprint|
      BlueprintParserJob.perform_later(blueprint.id)
    end
  end

  task recompute_factories: :environment do
    Blueprint::Factory.includes(:mod).where(mod: { name: "Dyson Sphere Program" }).each do |blueprint|
      BlueprintParserJob.perform_later(blueprint.id)
    end
  end

  task recompute_dyson_spheres: :environment do
    Blueprint::DysonSphere.includes(:mod).where(mod: { name: "Dyson Sphere Program" }).each do |blueprint|
      BlueprintParserJob.perform_later(blueprint.id)
    end
  end
end
