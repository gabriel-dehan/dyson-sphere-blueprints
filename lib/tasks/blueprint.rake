namespace :blueprint do
  desc "Fetches the latest versions of all managed mods"
  task recompute_data: :environment do
    Blueprint.all.each do |blueprint|
      Parsers::MultibuildBetaBlueprint.new(blueprint).parse!
    end
  end
end
