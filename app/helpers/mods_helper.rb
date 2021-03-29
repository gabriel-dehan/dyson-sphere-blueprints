module ModsHelper

  def formatted_mod_compatibility_range(blueprint)
    # if blueprint.mod.name == "MultiBuild"
    #   range = @mods.find { |mod| mod.name == 'MultiBuildBeta' }.compatibility_range_for(blueprint.mod_version)
    # else
    #   range = blueprint.mod_compatibility_range
    # end

    # Use MultiBuildBeta compatibility range anyway because MultiBuild and ``Beta are pretty much the same mod and have the same versions (for now)
    range = @mods.find { |mod| mod.name == 'MultiBuildBeta' }.compatibility_range_for(blueprint.mod_version)

    if range.first == range.last
      "<strong>range.first</strong>".html_safe
    else
      "<strong>#{range.first}</strong> up to <strong>#{range.last}</strong>".html_safe
    end
  end

  def compatibility_recap(blueprint)
    mod = blueprint.mod
    latest = mod.latest
    latest_breaking = mod.latest_breaking
    # Same, we use multibuildbeta data for displaying the range for both MultiBuild and ``Beta
    range = @mods.find { |mod| mod.name == 'MultiBuildBeta' }.compatibility_range_for(blueprint.mod_version)

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