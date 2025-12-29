module GameVersionsHelper
  def formatted_game_version_compatibility_range(game_versions, blueprint)
    game_version = game_versions.first
    range = game_version.compatibility_range_for(blueprint.game_version_string)

    if range.first == range.last
      "<strong>#{range.first}</strong>".html_safe # rubocop:disable Rails/OutputSafety
    else
      "Up to version <strong>#{range.last}</strong>".html_safe # rubocop:disable Rails/OutputSafety
    end
  end

  def compatibility_recap(game_versions, blueprint)
    game_version = blueprint.game_version
    latest = game_version.latest
    latest_breaking = game_version.latest_breaking
    range = game_versions.first.compatibility_range_for(blueprint.game_version_string)

    # Latest
    if blueprint.game_version_string == latest
      [:latest, "Latest"]
    # Slightly outdated
    elsif blueprint.game_version_string >= latest_breaking
      [:compatible, "Compatible up to #{range.last}"]
    # Totally outdated
    else
      [:outdated, "Outdated but compatible up to #{range.last}"]
    end
  end
end
