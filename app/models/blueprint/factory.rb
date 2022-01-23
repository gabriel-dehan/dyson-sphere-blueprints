class Blueprint::Factory < Blueprint
  def self.sti_name; "Factory"; end
  def normalize_friendly_id(string); "factory-#{super}"; end

  # Pictures
  include PictureUploader::Attachment(:cover_picture)
  acts_as_votable

  after_save :decode_blueprint

  validates :tag_list, length: { minimum: 1, maximum: 10, message: "needs at least one tag, maximum 10." }
  validates :cover_picture, presence: true
  validates :encoded_blueprint, presence: true
  validate :encoded_blueprint_parsable

  def large_bp?
    return false unless encoded_blueprint

    encoded_blueprint.size > 700_000
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
      valid = Parsers::FactoryBlueprint.new(self).validate
    else
      valid = true
    end

    errors.add(:encoded_blueprint, "Wrong blueprint format for mod version: #{mod.name} - #{mod_version}") if !valid
  end
end
