class Blueprint < ApplicationRecord
  extend FriendlyId
  acts_as_votable
  acts_as_taggable_on :tags

  has_one_attached :cover
  has_many_attached :pictures

  belongs_to :collection
  belongs_to :mod
  has_one :user, through: :collection

  friendly_id :title, use: :slugged

  validates :title, presence: true
  validates :encoded_blueprint, presence: true

  validates :tag_list, length: { minimum: 1, message: "needs at least one tag." }
  # validates :mod_version, format: { with: /((Dyson Sphere Program)|(MultiBuildBeta)|(MultiBuild))\s?-\s?\d+\.\d+.\d+((\.|-)\w+)?/i, message:  "Unregistered mod or version format." }

  validates :cover,
    attached: true,
    content_type: [:png, :jpg, :jpeg, :gif],
    dimension: {
      width: { max: 3000 },
      height: { max: 3000 },
      message: 'is too large'
    }

  validates :pictures,
    limit: { max: 5 },
    content_type: [:png, :jpg, :jpeg, :gif],
    dimension: {
      width: { max: 3000 },
      height: { max: 3000 },
      message: 'is too large'
    }

    def formatted_mod_version
      "#{mod.name} - #{mod_version}"
    end
end
