namespace :mod do
  desc "Fetches the latest versions of all managed mods"
  task fetch_latest: :environment do
    ModManagerJob.perform_later
  end

  # noglob rake 'mod:flag_breaking[MultiBuildBeta, 2.1.0]'
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
