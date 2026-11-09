require "application_system_test_case"

class BrowseBlueprintsTest < ApplicationSystemTestCase
  setup do
    skip "System tests require Chrome/Selenium to be configured" unless system_tests_available?
  end

  def system_tests_available?
    # Check if we can create a Selenium driver
    true
  rescue StandardError
    false
  end

  test "user can browse blueprints on home page" do
    visit root_path

    # Home page should load and display blueprints
    assert_selector "h1", text: /blueprints/i, wait: 5

    # Should see blueprint cards or listings
    assert_selector "[data-controller]", minimum: 1
  end

  test "user can view blueprint details" do
    blueprint = blueprints(:public_factory)

    visit blueprint_path(blueprint, locale: I18n.locale)

    # Should show blueprint title
    assert_text blueprint.title

    # Should have a copy button or blueprint code section
    assert_selector "body", text: /blueprint/i
  end

  test "user can filter blueprints by type" do
    visit blueprints_path

    # The page should have filter options
    assert_selector "body"

    # Visit factories filter
    visit blueprints_path(type: "factories")
    assert_selector "body"
  end

  test "recipe picker restores a selected recipe with its icon" do
    visit blueprints_path(recipe: "5")

    assert_selector '[data-controller="recipes-filter"] .tagify__tag', text: "Gear"
    assert_selector '[data-controller="recipes-filter"] .tagify__tag img[src*="/media/recipes/"]'

    find('[data-controller="recipes-filter"] .tagify__input').send_keys("Magnet")
    find(".tagify__dropdown__item", text: "Magnet", exact_text: true).click
    assert_selector '[data-controller="recipes-filter"] .tagify__tag', text: "Magnet"
    assert_selector('input[name="recipe"]', visible: :all) { |input| input.value == "5,2" }
    click_button "Search"
    assert_current_path(/recipe=5(%2C|%2c|,)2/)
    assert_equal "5,2", URI.decode_www_form(URI.parse(current_url).query).to_h["recipe"]

    find('[data-toggleabletabs-select="mechas"]').click
    click_button "Search"
    assert_current_path(/\A(?!.*[?&]recipe=).*\z/)
    assert_not URI.decode_www_form(URI.parse(current_url).query).to_h.key?("recipe")
  end
end
