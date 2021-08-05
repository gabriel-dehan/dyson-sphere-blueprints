module ModsHelper

  def formatted_mod_compatibility_range(blueprint)
    # TODO: Handle any mod
    # if blueprint.mod.name == "MultiBuild"
    #   range = @mods.find { |mod| mod.name == 'MultiBuildBeta' }.compatibility_range_for(blueprint.mod_version)
    # else
    #   range = blueprint.mod_compatibility_range
    # end

    base_mod = @mods.find { |mod| mod.name == 'Dyson Sphere Program' }
    range = base_mod.compatibility_range_for(blueprint.mod_version)

    if range.first == range.last
      "<strong>#{range.first}</strong>".html_safe
    else
      # TODO: Handle retro compatible patches properly
      "<strong>#{range.first}</strong> up to <strong>#{base_mod.latest}</strong>".html_safe
      # Correct: "<strong>#{range.first}</strong> up to <strong>#{range.last}</strong>".html_safe
    end
  end

  def compatibility_recap(blueprint)
    mod = blueprint.mod
    latest = mod.latest
    latest_breaking = mod.latest_breaking
    range = @mods.find { |mod| mod.name == 'Dyson Sphere Program' }.compatibility_range_for(blueprint.mod_version)

    # Latest
    if blueprint.mod_version == latest
      [:latest, "Latest"]
    # Slightly outdated
    elsif blueprint.mod_version >= latest_breaking
      [:compatible, "Compatible up to #{range.last}"]
    # Totally outdated
    else
      [:outdated, "Outdated but compatible up to #{range.last}"]
    end
  end
end