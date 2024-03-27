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

    test "should create mapping" do
      visit mappings_url
      click_on "New mapping"

      fill_in "Default", with: @mapping.default
      fill_in "Evaluate", with: @mapping.evaluate
      fill_in "Json paths", with: @mapping.json_paths
      fill_in "Obj name", with: @mapping.obj_name
      fill_in "Origin", with: @mapping.origin
      fill_in "Other", with: @mapping.other
      fill_in "Target", with: @mapping.target
      fill_in "Target type", with: @mapping.target_type
      click_on "Create Mapping"

      assert_text "Mapping was successfully created"
      click_on "Back"
    end

    test "should update Mapping" do
      visit mapping_url(@mapping)
      click_on "Edit this mapping", match: :first

      fill_in "Default", with: @mapping.default
      fill_in "Evaluate", with: @mapping.evaluate
      fill_in "Json paths", with: @mapping.json_paths
      fill_in "Obj name", with: @mapping.obj_name
      fill_in "Origin", with: @mapping.origin
      fill_in "Other", with: @mapping.other
      fill_in "Target", with: @mapping.target
      fill_in "Target type", with: @mapping.target_type
      click_on "Update Mapping"

      assert_text "Mapping was successfully updated"
      click_on "Back"
    end

    test "should destroy Mapping" do
      visit mapping_url(@mapping)
      click_on "Destroy this mapping", match: :first

      assert_text "Mapping was successfully destroyed"
    end
  end
end
