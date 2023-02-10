require "application_system_test_case"

module XrefClient
  class MappingsTest < ApplicationSystemTestCase
    setup do
      @mapping = xref_client_mappings(:one)
    end

    test "visiting the index" do
      visit mappings_url
      assert_selector "h1", text: "Mappings"
    end

    test "creating a Mapping" do
      visit mappings_url
      click_on "New Mapping"

      fill_in "Default", with: @mapping.default
      fill_in "Evaluate", with: @mapping.evaluate
      fill_in "Json paths", with: @mapping.json_paths
      fill_in "Obj name", with: @mapping.obj_name
      fill_in "Origin", with: @mapping.origin
      fill_in "Other", with: @mapping.other
      fill_in "Target", with: @mapping.target
      fill_in "Type", with: @mapping.target_type
      click_on "Create Mapping"

      assert_text "Mapping was successfully created"
      click_on "Back"
    end

    test "updating a Mapping" do
      visit mappings_url
      click_on "Edit", match: :first

      fill_in "Default", with: @mapping.default
      fill_in "Evaluate", with: @mapping.evaluate
      fill_in "Json paths", with: @mapping.json_paths
      fill_in "Obj name", with: @mapping.obj_name
      fill_in "Origin", with: @mapping.origin
      fill_in "Other", with: @mapping.other
      fill_in "Target", with: @mapping.target
      fill_in "Type", with: @mapping.target_type
      click_on "Update Mapping"

      assert_text "Mapping was successfully updated"
      click_on "Back"
    end

    test "destroying a Mapping" do
      visit mappings_url
      page.accept_confirm do
        click_on "Destroy", match: :first
      end

      assert_text "Mapping was successfully destroyed"
    end
  end
end
