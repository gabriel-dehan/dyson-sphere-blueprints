namespace :blueprint do
  desc "Recompute all blueprint datas"
  task recompute_data: :environment do
    Blueprint.where(mod: { name: "Dyson Sphere Program" }).each do |blueprint|
      BlueprintParserJob.perform_later(blueprint.id)
    end
  end
end
