class Collection < ApplicationRecord
  self.inheritance_column = :kind
  extend FriendlyId
  paginates_per 20

  enum type: { "Public" => 0, "Private" => 1 }

  belongs_to :user
  has_many :blueprints, dependent: :destroy

  friendly_id :name, use: :slugged

  def total_votes
    # TODO: Remove MB
    blueprints.where(mod_id: Mod.last.id).distinct.sum(:cached_votes_total)
  end
end
