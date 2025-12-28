class Blueprint::DysonSphere < Blueprint
  def self.sti_name() = "DysonSphere"

  def normalize_friendly_id(string) = "dyson-sphere-#{super}"

  # Pictures
  include PictureUploader::Attachment(:cover_picture)
  acts_as_votable

  after_save :decode_blueprint

  validates :tag_list, length: { maximum: 10, message: "maximum 10 tags." }
  validates :cover_picture, presence: true
  validates :encoded_blueprint, presence: true
  validate :encoded_blueprint_parsable

  def large_bp?
    return false unless encoded_blueprint

    encoded_blueprint.size > 700_000
  end

  private

  def decode_blueprint
    BlueprintParserJob.perform_later(id) if saved_change_to_attribute?(:encoded_blueprint)
  end

  def encoded_blueprint_parsable
    if !id || will_save_change_to_attribute?(:encoded_blueprint)
      valid = Parsers::DysonSphereBlueprint.new(self).validate
      errors.add(:encoded_blueprint, "Wrong blueprint format for game version: #{mod.name} - #{mod_version}") if !valid
    end
  end
end
