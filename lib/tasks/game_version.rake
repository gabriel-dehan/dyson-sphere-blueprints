namespace :game_version do
  # noglob rake 'game_version:fetch_latest[0.9.24.11182]'
  desc "Update the latest version of the game"
  task :fetch_latest, [:patch] => [:environment] do |_t, args|
    BaseGameManagerJob.perform_later(args[:patch])
  end

  # noglob rake 'game_version:flag_breaking[0.9.24.11182]'
  desc "Flag a game version as breaking"
  task :flag_breaking, [:patch] => [:environment] do |_t, args|
    game_version = GameVersion.first

    temp_version_list = game_version.versions.dup
    version = temp_version_list[args[:patch]]
    version["breaking"] = true
    temp_version_list[args[:patch]] = version

    game_version.update!(versions: temp_version_list)
    puts "Done!"
  end

  # noglob rake 'game_version:unflag_breaking[0.9.24.11182]'
  desc "Unflag a game version as breaking"
  task :unflag_breaking, [:patch] => [:environment] do |_t, args|
    game_version = GameVersion.first

    temp_version_list = game_version.versions.dup
    version = temp_version_list[args[:patch]]
    version["breaking"] = false
    temp_version_list[args[:patch]] = version

    game_version.update!(versions: temp_version_list)
    puts "Done!"
  end
end
