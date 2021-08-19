namespace :mod do
  desc "Fetches the latest versions of all managed mods"
  task fetch_latest: :environment do
    ModManagerJob.perform_later
  end

  # noglob rake 'mod:fetch_base_game_latest[0.8.19.7662]'
  desc "Update the latest version of the game"
  task :fetch_base_game_latest, [:patch] => [:environment] do |t, args|
    BaseGameManagerJob.perform_now(args[:patch])
  end

  # noglob rake 'mod:flag_breaking[MultiBuildBeta, 2.1.0]'
  # noglob rake 'mod:flag_breaking[Dyson Sphere Program, 0.8.19.7662]'
  desc "Flag a mod version as breaking"
  task :flag_breaking, [:name, :patch] => [:environment] do |t, args|
    mod = Mod.find_by_name(args[:name])

    temp_version_list = mod.versions.dup
    version = temp_version_list[args[:patch]]
    version["breaking"] = true
    temp_version_list[args[:patch]] = version

    mod.update!(versions: temp_version_list)
    puts "Done!"
  end

  # noglob rake 'mod:unflag_breaking[MultiBuildBeta, 2.1.0]'
  desc "Unflag a mod version as breaking"
  task :unflag_breaking, [:name, :patch] => [:environment] do |t, args|
    mod = Mod.find_by_name(args[:name])

    temp_version_list = mod.versions.dup
    version = temp_version_list[args[:patch]]
    version["breaking"] = false
    temp_version_list[args[:patch]] = version

    mod.update!(versions: temp_version_list)
    puts "Done!"
  end
end