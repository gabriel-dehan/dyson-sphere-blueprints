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

  def self.trending
    # Calculate trending score for all blueprints (no time restriction)
    # Older blueprints can trend again if they get recent engagement
    #
    # What counts:
    # - Votes (likes): Recent votes (last 7 days) x 3.0, Total votes x 2.0
    # - Copies/Downloads: Recent copies (last 7 days) x 1.5, Total copies x 1.0
    # - Time boost: 7 days = 30% boost, 30 days = 15% boost, older = no boost
    seven_days_ago = connection.quote(7.days.ago)
    # rubocop:disable Rails/SquishedSQLHeredocs
    trending_query = <<-SQL
      WITH blueprint_scores AS (
        SELECT blueprints.id,
          (
            -- Recent engagement (last 7 days weighted more heavily)
            (
              COALESCE((SELECT COUNT(*) FROM votes WHERE votes.votable_id = blueprints.id AND votes.votable_type = 'Blueprint' AND votes.created_at >= #{seven_days_ago}), 0) * 3.0 +
              COALESCE((SELECT COUNT(*) FROM blueprint_usage_metrics WHERE blueprint_usage_metrics.blueprint_id = blueprints.id AND blueprint_usage_metrics.last_used_at >= #{seven_days_ago}), 0) * 1.5
            ) * 2.0 +  -- Double weight for recent activity
            -- Total engagement
            (blueprints.cached_votes_total * 2.0 +
              blueprints.usage_count * 1.0)
          ) *
          -- Time boost: 7 days = 30% boost, 30 days = 15% boost, older = no boost
          CASE
            WHEN blueprints.created_at >= NOW() - INTERVAL '7 days' THEN 1.3
            WHEN blueprints.created_at >= NOW() - INTERVAL '30 days' THEN 1.15
            ELSE 1.0
          END
          as trending_score
        FROM blueprints
      )
      SELECT blueprints.*, COALESCE(blueprint_scores.trending_score, 0) as trending_score
      FROM blueprints
      LEFT JOIN blueprint_scores ON blueprint_scores.id = blueprints.id
    SQL
    # rubocop:enable Rails/SquishedSQLHeredocs

    from("(#{trending_query}) AS blueprints")
      .includes(:game_version, :tags, :user)
      .order("trending_score DESC")
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
    type_name = "Blueprint::#{type_name}" unless type_name.start_with?("Blueprint::")
    super
  end
end
