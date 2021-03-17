class Blueprint < ApplicationRecord
  include GameDataConcern
  include PgSearch::Model
  extend FriendlyId
  acts_as_votable
  acts_as_taggable_on :tags
  paginates_per 50

  has_rich_text :description
  has_one_attached :cover
  has_many_attached :pictures

  belongs_to :collection
  belongs_to :mod
  has_one :user, through: :collection

  friendly_id :title, use: :slugged

  after_save :decode_blueprint

  pg_search_scope :search_by_title,
    against: [:title],
    using: {
      tsearch: { prefix: true }
    }

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

    default_scope { with_rich_text_description }

    def formatted_mod_version
      "#{mod.name} - #{mod_version}"
    end

    private
    def decode_blueprint
      # TODO: Check if this should be a background job
      if saved_change_to_attribute?(:encoded_blueprint)
        BlueprintParserJob.perform_now(self.id)
      end
    end
end
