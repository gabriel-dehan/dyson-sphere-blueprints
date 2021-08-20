class Mod < ApplicationRecord
  has_many :blueprints, dependent: :restrict_with_error

  # Used to decide which mods are automaticaly fetched from the thunderstore API
  MANAGED_MODS = [
    "MultiBuild",
    "MultiBuildBeta",
    "Dyson Sphere Program"
  ].freeze

  def self.to_select
    all.map { |mod| [mod.name, mod.id] }
  end

  def latest
    version_list.first
  end

  # Returns the latest version with a breaking change to blueprint format
  def latest_breaking
    versions.sort.reverse.find { |_, data| data["breaking"] }&.first
  end

  # Version list sorted DESC
  def version_list
    versions.keys.sort.reverse
  end

  # TODO: Handle backward compatible and non compatible versions
  # Returns a range of version strings compatible with check_version, e.g ["2.0.0", "3.0.0"]
  def compatibility_range_for(check_version)
    # Generates a version matrix [[version, breaking]], e.g: [["2.0.1", true], ["2.0.2", false], ...]
    version_list = versions.sort.map { |v, data| [v, data["breaking"]] }

    # Find the first version <= to the blueprint.mod_version that is breaking
    lower_breaking_index = version_list.rindex { |version, breaking| version <= check_version && breaking } || 0

    # The lowbound range is everything from the lower_breaking_index (not included) up to the latest version
    lowbound_range = version_list[(lower_breaking_index + 1)..version_list.length - 1]
    # Find the last version > to the blueprint.mod_version that is breaking
    upper_breaking_index = lowbound_range.find_index { |_version, breaking| breaking }

    # Lowest version possible
    lowest_version  = version_list[lower_breaking_index]
    # Highest version possible, if non was found (there is no breaking version in the lowbound range) use the latest version
    highest_version = upper_breaking_index ? lowbound_range[upper_breaking_index - 1] : version_list.last

    [lowest_version[0], highest_version[0]]
  end

  # Returns an array of version strings compatible with check_version, e.g ["2.0.0", "2.0.1", "2.0.2"]
  def compatibility_list_for(check_version)
    compatibility_range = compatibility_range_for(check_version)

    versions
      .filter { |v, _data| v >= compatibility_range.first && v <= compatibility_range.last }
      .keys
      .sort
  end
end
