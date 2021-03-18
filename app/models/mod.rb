class Mod < ApplicationRecord
  has_many :blueprints

  MANAGED_MODS = [
    'MultiBuildBeta'
  ]

  def self.to_select
    self.all.map { |mod| [mod.name, mod.id] }
  end

  def version_list
    versions.keys.sort.reverse
  end
end
