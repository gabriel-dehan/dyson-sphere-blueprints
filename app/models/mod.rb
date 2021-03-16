class Mod < ApplicationRecord
  has_many :blueprints

  MANAGED_MODS = [
    'MultiBuildBeta'
  ]

  def version_list
    versions.keys
  end
end
