class Collection < ApplicationRecord
  self.inheritance_column = :kind
  extend FriendlyId
  friendly_id :name, use: :slugged

  paginates_per 20

  enum type: { "Public" => 0, "Private" => 1 }

  belongs_to :user
  has_many :blueprints, dependent: :destroy
  has_many :factory_blueprints, dependent: :destroy, class_name: "Blueprint::Factory"
  has_many :dyson_sphere_blueprints, dependent: :destroy, class_name: "Blueprint::DysonSphere"
  has_many :mecha_blueprints, dependent: :destroy, class_name: "Blueprint::Mecha"

  def total_votes
    blueprints.distinct.sum(:cached_votes_total)
  end
end
