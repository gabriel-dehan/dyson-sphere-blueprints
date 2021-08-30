class Blueprint < ApplicationRecord
  include PgSearch::Model
  extend FriendlyId

  acts_as_votable
  acts_as_taggable_on :tags
  paginates_per 32

  # Pictures
  include PictureUploader::Attachment(:cover_picture)
  has_many :additional_pictures, dependent: :destroy, class_name: "Picture"
  accepts_nested_attributes_for :additional_pictures, allow_destroy: true

  belongs_to :collection
  belongs_to :mod
  has_one :user, through: :collection

  has_rich_text :description

  friendly_id :title, use: :slugged

  after_save :decode_blueprint

  validates :title, presence: true
  validates :encoded_blueprint, presence: true
  validates :tag_list, length: { minimum: 1, maximum: 10, message: "needs at least one tag, maximum 10." }
  validates :cover_picture, presence: true
  validates :additional_pictures, length: { maximum: 4, message: "Too many pictures. Please make sure you don't have too many pictures attached." }
  validate :encoded_blueprint_parsable

  pg_search_scope :search_by_title,
                  against: [:title],
                  using: {
                    tsearch: { prefix: true },
                  }

  # scope :with_relations, -> { with_rich_text_description.includes(:tags, :tag_taggings, :mod, :user, :additional_pictures) }
  default_scope { includes(:tags, :tag_taggings, :user) }

  def formatted_mod_version
    "#{mod.name} - #{mod_version}"
  end

  def tags_without_mass_construction
    tags.reject { |tag| tag.name =~ /mass construction/i }
  end

  def is_mod_version_latest?
    mod_version >= mod.latest
  end

  def mod_compatibility_range
    # Handle retro compatibility only for <= 2.0.6
    if mod_version <= "2.0.6"
      [
        mod.compatibility_range_for(mod_version).first,
        mod.compatibility_range_for(mod.latest).last
      ]
    else
      mod.compatibility_range_for(mod_version)
    end
  end

  private

  def decode_blueprint
    BlueprintParserJob.perform_now(id) if saved_change_to_attribute?(:encoded_blueprint)
  end

  def encoded_blueprint_parsable
    if mod.name == "MultiBuildBeta"
      valid = Parsers::MultibuildBetaBlueprint.new(self).validate
    elsif mod.name == "MultiBuild"
      valid = Parsers::MultibuildBetaBlueprint.new(self).validate
    elsif mod.name == "Dyson Sphere Program"
      valid = Parsers::DysonSphereProgramBlueprint.new(self).validate
    else
      valid = true
    end

    errors.add(:encoded_blueprint, "Wrong blueprint format for mod version: #{mod.name} - #{mod_version}") if !valid
  end
end
