class Blueprint < ApplicationRecord
  include PgSearch::Model
  extend FriendlyId
  friendly_id :title, use: :slugged

  acts_as_votable
  acts_as_taggable_on :tags
  paginates_per 32

  belongs_to :collection
  belongs_to :mod
  has_one :user, through: :collection
  has_many :comments, dependent: :destroy

  # Pictures
  has_many :additional_pictures, dependent: :destroy, class_name: "Picture"
  accepts_nested_attributes_for :additional_pictures, allow_destroy: true
  has_rich_text :description

  validates :title, presence: true
  validates :additional_pictures, length: { maximum: 4, message: "Too many pictures. Please make sure you don't have too many pictures attached." }

  # Hides other mods as long as we don't have a need for them
  default_scope { includes(:mod, :tags, :tag_taggings, :user).where(mod: { name: "Dyson Sphere Program" }) }
  scope :light_query, -> { select(column_names - ['encoded_blueprint']) }

  pg_search_scope :search_by_title,
                  against: [:title],
                  using: {
                    tsearch: { prefix: true },
                  }

  def self.trending
    # Get blueprints from the last 30 days and calculate trending score
    trending_query = <<-SQL
      WITH blueprint_scores AS (
        SELECT blueprints.id,
          (
            -- Recent engagement (last 7 days weighted more heavily)
            (
              COALESCE((SELECT COUNT(*) FROM votes WHERE votes.votable_id = blueprints.id AND votes.created_at >= '#{7.days.ago}'), 0) * 2.0 +
              COALESCE((SELECT COUNT(*) FROM comments WHERE comments.blueprint_id = blueprints.id AND comments.created_at >= '#{7.days.ago}'), 0) * 3.0 +
              blueprints.usage_count * 4.0  -- Using usage_count directly
            ) * 2.0 +  -- Double weight for recent activity
            -- Total engagement
            (blueprints.cached_votes_total * 1.0 + 
             COALESCE((SELECT COUNT(*) FROM comments WHERE comments.blueprint_id = blueprints.id), 0) * 2.0 +
             blueprints.usage_count * 3.0)
          ) * 
          -- Time boost: newer blueprints get a small boost
          (1.0 + (1.0 - (EXTRACT(EPOCH FROM (blueprints.created_at - '#{30.days.ago}'::timestamp)) / 2592000.0)) * 0.5)
          as trending_score
        FROM blueprints
        WHERE blueprints.created_at >= '#{30.days.ago}'
      )
      SELECT blueprints.*, COALESCE(blueprint_scores.trending_score, 0) as trending_score
      FROM blueprints
      LEFT JOIN blueprint_scores ON blueprint_scores.id = blueprints.id
    SQL

    from("(#{trending_query}) AS blueprints")
      .includes(:mod, :tags, :tag_taggings, :user)
      .order('trending_score DESC')
  end

  def tags_without_mass_construction
    tags.reject { |tag| tag.name =~ /mass construction/i }
  end

  def formatted_mod_version
    "#{mod.name} - #{mod_version}"
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
