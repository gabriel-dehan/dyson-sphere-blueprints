module ModsHelper

  def formatted_mod_compatibility_range(blueprint)
    range = blueprint.mod_compatibility_range
    if range.first == range.last
      "<strong>range.first</strong>".html_safe
    else
      "<strong>#{range.first}</strong> up to <strong>#{range.last}</strong>".html_safe
    end
  end

  def compatibility_recap(blueprint)
    latest = blueprint.mod.latest
    latest_breaking = blueprint.mod.latest_breaking

    # Latest
    if blueprint.mod_version == latest
      [:latest, "Latest"]
    # Slightly outdated
    elsif blueprint.mod_version >= latest_breaking
      [:compatible, "Compatible up to #{blueprint.mod_compatibility_range.last}"]
    # Totally outdated
    else
      [:outdated, "Outdated but compatible up to #{blueprint.mod_compatibility_range.last}"]
    end
  end
end