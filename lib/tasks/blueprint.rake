namespace :blueprint do
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
