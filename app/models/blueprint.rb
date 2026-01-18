class Blueprint < ApplicationRecord
  include PgSearch::Model
  extend FriendlyId
  friendly_id :title, use: :slugged

  acts_as_votable
  acts_as_taggable_on :tags

  # Configuration constants for trending algorithm
  RECENT_WINDOW = 7.days
  RECENT_VOTE_WEIGHT = 3.0
  RECENT_COPY_WEIGHT = 1.5
  RECENT_ACTIVITY_MULTIPLIER = 2.0
  TOTAL_VOTE_WEIGHT = 2.0
  TOTAL_USAGE_WEIGHT = 1.0
  
  # Time boost constants
  NEW_BLUEPRINT_WINDOW = 30.days
  NEW_BLUEPRINT_BOOST = 1.3
  RECENT_BLUEPRINT_WINDOW = 60.days
  RECENT_BLUEPRINT_BOOST = 1.15
  OLD_BLUEPRINT_BOOST = 1.0
  
  # Other configuration
  MAX_ADDITIONAL_PICTURES = 4
  BLUEPRINTS_PER_PAGE = 32
  RETRO_COMPATIBILITY_VERSION = "2.0.6"

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
    # - Votes (likes): Recent votes x RECENT_VOTE_WEIGHT, Total votes x TOTAL_VOTE_WEIGHT
    # - Copies/Downloads: Recent copies x RECENT_COPY_WEIGHT, Total copies x TOTAL_USAGE_WEIGHT
    # - Time boost: NEW_BLUEPRINT_WINDOW = NEW_BLUEPRINT_BOOST, RECENT_BLUEPRINT_WINDOW = RECENT_BLUEPRINT_BOOST, older = OLD_BLUEPRINT_BOOST
    recent_window_ago = connection.quote(RECENT_WINDOW.ago)
    new_blueprint_days = (NEW_BLUEPRINT_WINDOW / 1.day).to_i
    recent_blueprint_days = (RECENT_BLUEPRINT_WINDOW / 1.day).to_i
    
    # Use light_query columns (exclude encoded_blueprint to avoid memory issues)
    light_columns = (column_names - ["encoded_blueprint"]).map { |col| "blueprints.#{col}" }.join(", ")
    
    # rubocop:disable Rails/SquishedSQLHeredocs
    trending_query = <<-SQL
      WITH recent_votes AS (
        SELECT votable_id, COUNT(*) as votes_count
        FROM votes
        WHERE votable_type = 'Blueprint' AND created_at >= #{recent_window_ago}
        GROUP BY votable_id
      ),
      recent_usage AS (
        SELECT blueprint_id, COUNT(*) as usages_count
        FROM blueprint_usage_metrics
        WHERE last_used_at >= #{recent_window_ago}
        GROUP BY blueprint_id
      ),
      blueprint_scores AS (
        SELECT blueprints.id,
          (
            -- Recent engagement (last #{new_blueprint_days} days weighted more heavily)
            (
              COALESCE(rv.votes_count, 0) * #{RECENT_VOTE_WEIGHT} +
              COALESCE(ru.usages_count, 0) * #{RECENT_COPY_WEIGHT}
            ) * #{RECENT_ACTIVITY_MULTIPLIER} +  -- Multiplier for recent activity
            -- Total engagement
            (blueprints.cached_votes_total * #{TOTAL_VOTE_WEIGHT} +
              blueprints.usage_count * #{TOTAL_USAGE_WEIGHT})
          ) *
          -- Time boost: #{new_blueprint_days} days = #{((NEW_BLUEPRINT_BOOST - 1) * 100).to_i}% boost, #{recent_blueprint_days} days = #{((RECENT_BLUEPRINT_BOOST - 1) * 100).to_i}% boost, older = no boost
          CASE
            WHEN blueprints.created_at >= NOW() - INTERVAL '#{new_blueprint_days} days' THEN #{NEW_BLUEPRINT_BOOST}
            WHEN blueprints.created_at >= NOW() - INTERVAL '#{recent_blueprint_days} days' THEN #{RECENT_BLUEPRINT_BOOST}
            ELSE #{OLD_BLUEPRINT_BOOST}
          END
          as trending_score
        FROM blueprints
        LEFT JOIN recent_votes rv ON rv.votable_id = blueprints.id
        LEFT JOIN recent_usage ru ON ru.blueprint_id = blueprints.id
      )
      SELECT #{light_columns}, COALESCE(blueprint_scores.trending_score, 0) as trending_score
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
end
