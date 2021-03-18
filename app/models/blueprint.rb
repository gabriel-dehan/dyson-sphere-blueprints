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

  validates :tag_list, length: { minimum: 1, maximum: 10, message: "needs at least one tag, maximum 10." }
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
    limit: { max: 4 },
    content_type: [:png, :jpg, :jpeg, :gif],
    dimension: {
      width: { max: 3000 },
      height: { max: 3000 },
      message: 'is too large'
    }

  validate :encoded_blueprint_parsable

  default_scope { with_rich_text_description }

  def formatted_mod_version
    "#{mod.name} - #{mod_version}"
  end

  private
  def decode_blueprint
    if saved_change_to_attribute?(:encoded_blueprint)
      BlueprintParserJob.perform_now(self.id)
    end
  end

  # TODO: Refactor, cleanup, make validator and parsers distinct
  def encoded_blueprint_parsable
    if self.mod.name === "MultiBuildBeta"
      if self.mod_version <= "2.0.6"
        valid = MultibuildBetaBlueprintParser::parse_version_206(self, validate: true)
      else
        valid = MultibuildBetaBlueprintParser::parse_version_207(self, validate: true)
      end
    end

    if !valid
      errors.add(:encoded_blueprint, "Wrong blueprint format for mod version: #{self.mod.name} - #{self.mod_version}")
    end
  end
end
