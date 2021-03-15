class Collection < ApplicationRecord
  self.inheritance_column = :kind
  extend FriendlyId

  enum type: ["Public", "Private"]

  belongs_to :user
  has_many :blueprints, dependent: :destroy

  friendly_id :name, use: :slugged
end
