class Blueprint < ApplicationRecord
  include PgSearch::Model
  extend FriendlyId
  friendly_id :title, use: :slugged

  acts_as_votable
  acts_as_taggable_on :tags

  # Other configuration
  MAX_ADDITIONAL_PICTURES = 4
  BLUEPRINTS_PER_PAGE = 32
  RETRO_COMPATIBILITY_VERSION = "2.0.6".freeze

  paginates_per BLUEPRINTS_PER_PAGE

  belongs_to :collection
  belongs_to :game_version
  has_one :user, through: :collection

  # Pictures
  has_many :additional_pictures, dependent: :destroy, class_name: "Picture"
  accepts_nested_attributes_for :additional_pictures, allow_destroy: true
  has_rich_text :description

  validates :title, presence: true
  validates :additional_pictures, length: { maximum: MAX_ADDITIONAL_PICTURES, message: "Too many pictures. Please make sure you don't have too many pictures attached." }

  scope :light_query, -> { select(column_names - ["encoded_blueprint"]) }
  scope :with_associations, -> { includes(:game_version, :tags, :user, :collection, collection: :user) }

  before_save :set_recipe_ids, if: :will_save_change_to_summary?

  pg_search_scope :search_by_title,
                  against: [:title],
                  using: {
                    tsearch: { prefix: true },
                  }

  def self.trending_generation
    return unless connection.data_source_exists?("blueprint_trending_scores") && connection.data_source_exists?("blueprint_trending_refreshes")

    connection.select_value("SELECT generation FROM blueprint_trending_refreshes WHERE id = 1").to_i
  end

  def self.trending
    relation = all
    relation = relation.select(relation.select_values.presence || "blueprints.*")
    fallback = "COALESCE(blueprints.cached_votes_total, 0) * 2.0 + COALESCE(blueprints.usage_count, 0)"
    if trending_generation.to_i.positive?
      score = "COALESCE(blueprint_trending_scores.score, #{fallback})"
      relation = relation.joins("LEFT JOIN blueprint_trending_scores ON blueprint_trending_scores.blueprint_id = blueprints.id")
    else
      score = fallback
    end
    relation.select("#{score} AS trending_score").reorder(Arel.sql("#{score} DESC, blueprints.id DESC"))
  end

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
    # Handle retro compatibility only for versions <= RETRO_COMPATIBILITY_VERSION
    if game_version_string <= RETRO_COMPATIBILITY_VERSION
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

  private

  def set_recipe_ids
    self.recipe_ids = extract_recipe_ids_from_summary
  end

  def extract_recipe_ids_from_summary
    return [] unless summary.is_a?(Hash)

    buildings = summary["buildings"] || summary[:buildings]
    return [] unless buildings.is_a?(Hash)

    buildings.values.flat_map do |building|
      next [] unless building.is_a?(Hash)

      recipes = building["recipes"] || building[:recipes]
      next [] unless recipes.is_a?(Hash)

      recipes.keys.filter_map do |key|
        value = key.to_s
        next unless value.match?(/\A[1-9]\d{0,9}\z/)

        id = value.to_i
        id if id <= 2_147_483_647
      end
    end.uniq.sort
  end
end
