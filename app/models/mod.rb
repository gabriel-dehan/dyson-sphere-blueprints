class Mod < ApplicationRecord
  has_many :blueprints

  # Used to decide which mods are automaticaly fetched from the thunderstore API
  MANAGED_MODS = [
    'MultiBuild',
    'MultiBuildBeta'
  ]

  def self.to_select
    self.all.map { |mod| [mod.name, mod.id] }
  end

  def latest
    version_list.first
  end

  # Returns the latest version with a breaking change to blueprint format
  def latest_breaking
    versions.sort.filter { |_, data| data["breaking"] }.last&.first
  end

  # Version list sorted DESC
  def version_list
    versions.keys.sort.reverse
  end

  # Returns a range of version strings compatible with check_version, e.g ["2.0.0", "3.0.0"]
  def compatibility_range_for(check_version)
    _versions = self.versions.sort.map { |v, data| [v, data["breaking"]] }
    # Find the first version <= to the blueprint.mod_version that is breaking
    lower_breaking_index = _versions.rindex { |version, breaking| version <= check_version && breaking } || 0
    # Find the last version > to the blueprint.mod_version that is breaking
    upper_breaking_index = _versions[(lower_breaking_index + 1).._versions.length - 1].find_index { |version, breaking| breaking } || _versions.length - 1

    [_versions[lower_breaking_index][0], _versions[upper_breaking_index][0]]
  end

  # Returns an array of version strings compatible with check_version, e.g ["2.0.0", "2.0.1", "2.0.2"]
  def compatibility_list_for(check_version)
    compatibility_range = self.compatibility_range_for(check_version)
    self
      .versions
      .filter { |v, data| v >= compatibility_range.first && v <= compatibility_range.last }
      .keys
      .sort
  end
end
