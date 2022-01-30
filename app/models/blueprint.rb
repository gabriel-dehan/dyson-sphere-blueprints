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

  # Pictures
  has_many :additional_pictures, dependent: :destroy, class_name: "Picture"
  accepts_nested_attributes_for :additional_pictures, allow_destroy: true
  has_rich_text :description

  validates :title, presence: true
  validates :additional_pictures, length: { maximum: 4, message: "Too many pictures. Please make sure you don't have too many pictures attached." }

  default_scope { includes(:tags, :tag_taggings, :user) }

  pg_search_scope :search_by_title,
                  against: [:title],
                  using: {
                    tsearch: { prefix: true },
                  }

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
