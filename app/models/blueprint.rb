class Blueprint < ApplicationRecord
  include PgSearch::Model
  extend FriendlyId
  friendly_id :title, use: :slugged

  acts_as_votable
  acts_as_taggable_on :tags
  paginates_per 32

  belongs_to :collection
  belongs_to :game_version
  has_one :user, through: :collection

  # Pictures
  has_many :additional_pictures, dependent: :destroy, class_name: "Picture"
  accepts_nested_attributes_for :additional_pictures, allow_destroy: true
  has_rich_text :description

  validates :title, presence: true
  validates :additional_pictures, length: { maximum: 4, message: "Too many pictures. Please make sure you don't have too many pictures attached." }

  scope :light_query, -> { select(column_names - ["encoded_blueprint"]) }
  scope :with_associations, -> { includes(:game_version, :tags, :user, :collection, collection: :user) }

  pg_search_scope :search_by_title,
                  against: [:title],
                  using: {
                    tsearch: { prefix: true },
                  }

  def tags_without_mass_construction
    tags.reject { |tag| tag.name =~ /mass construction/i }
  end

  def formatted_game_version
    "#{game_version.name} - #{game_version_string}"
  end

  def is_game_version_latest?
    game_version_string >= game_version.latest
  end

  def game_version_compatibility_range
    # Handle retro compatibility only for <= 2.0.6
    if game_version_string <= "2.0.6"
      [
        game_version.compatibility_range_for(game_version_string).first,
        game_version.compatibility_range_for(game_version.latest).last
      ]
    else
      game_version.compatibility_range_for(game_version_string)
    end
  end

  def large_bp?
    return false unless encoded_blueprint
  end

  def is_mecha?
    type == "Mecha"
  end

  def self.find_sti_class(type_name)
    type_name = "Blueprint::#{type_name}"
    super
  end
end
