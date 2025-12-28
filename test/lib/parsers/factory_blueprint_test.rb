require "test_helper"

class Parsers::FactoryBlueprintTest < ActiveSupport::TestCase
  test "validate returns truthy for valid DSP blueprint format" do
    blueprint = blueprints(:public_factory)
    parser = Parsers::FactoryBlueprint.new(blueprint)

    assert parser.validate
  end

  test "validate returns falsy for invalid format" do
    blueprint = Blueprint::Factory.new(
      encoded_blueprint: "INVALID_BLUEPRINT_STRING",
      mod_version: "0.9.27.15466"
    )
    parser = Parsers::FactoryBlueprint.new(blueprint)

    assert_not parser.validate
  end

  test "validate returns falsy for empty string" do
    blueprint = Blueprint::Factory.new(
      encoded_blueprint: "",
      mod_version: "0.9.27.15466"
    )
    parser = Parsers::FactoryBlueprint.new(blueprint)

    assert_not parser.validate
  end

  test "validate raises error for nil encoded_blueprint" do
    blueprint = Blueprint::Factory.new(
      encoded_blueprint: nil,
      mod_version: "0.9.27.15466"
    )
    parser = Parsers::FactoryBlueprint.new(blueprint)

    # Calling validate on nil encoded_blueprint will raise NoMethodError
    assert_raises(NoMethodError) do
      parser.validate
    end
  end

  test "validate accepts blueprint with correct header format" do
    # Test the regex pattern matching
    valid_blueprint = 'BLUEPRINT:0,10,2203,0,0,0,0,0,638229688703249448,0.9.27.15466,Test,"base64data"checksum'
    blueprint = Blueprint::Factory.new(
      encoded_blueprint: valid_blueprint,
      mod_version: "0.9.27.15466"
    )
    parser = Parsers::FactoryBlueprint.new(blueprint)

    assert parser.validate
  end

  test "parse! extracts building summary from valid blueprint" do
    blueprint = blueprints(:public_factory)
    # Ensure the blueprint has a collection so it can be saved
    blueprint.collection = collections(:member_public)
    parser = Parsers::FactoryBlueprint.new(blueprint)

    # parse! should not raise and should set summary
    parser.parse!(silent_errors: false)

    assert_not_nil blueprint.summary
    assert blueprint.summary.key?(:total_structures) || blueprint.summary.key?("total_structures")
  end

  test "parse! handles invalid blueprint gracefully with silent_errors" do
    blueprint = Blueprint::Factory.new(
      title: "Invalid BP",
      encoded_blueprint: "BLUEPRINT:0,1,2,3,4,5,6,7,8,0.9.27.15466,Test,\"invalid_base64\"checksum",
      mod_version: "0.9.27.15466",
      collection: collections(:member_public),
      mod: mods(:dsp)
    )
    parser = Parsers::FactoryBlueprint.new(blueprint)

    # Should not raise with silent_errors: true
    result = parser.parse!(silent_errors: true)

    # Returns nil when parsing fails
    assert_nil result
  end
end
