class Mod < ApplicationRecord
  has_many :blueprints

  MANAGED_MODS = [
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

  def version_list
    versions.keys.sort.reverse
  end

  def compatibility_range_for(check_version)
    _versions = self.versions.sort.map { |v, data| [v, data["breaking"]] }
    # Find the first version <= to the blueprint.mod_version that is breaking
    lower_breaking_index = _versions.rindex { |version, breaking| version <= check_version && breaking } || 0
    # Find the last version > to the blueprint.mod_version that is breaking
    upper_breaking_index = _versions[(lower_breaking_index + 1).._versions.length - 1].find_index { |version, breaking| breaking } || _versions.length - 1

    [_versions[lower_breaking_index][0], _versions[upper_breaking_index][0]]
  end
end
