class Collection < ApplicationRecord
  self.inheritance_column = :kind
  extend FriendlyId
  paginates_per 20

  enum type: ["Public", "Private"]

  belongs_to :user
  has_many :blueprints, dependent: :destroy

  friendly_id :name, use: :slugged

  def total_votes
    blueprints.sum(:cached_votes_total)
  end
end
