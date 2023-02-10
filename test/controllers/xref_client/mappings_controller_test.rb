require 'test_helper'

module XrefClient
  class MappingsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @mapping = xref_client_mappings(:one)
    end

    test "should get index" do
      get mappings_url
      assert_response :success
    end

    test "should get new" do
      get new_mapping_url
      assert_response :success
    end

    test "should create mapping" do
      assert_difference('Mapping.count') do
        post mappings_url, params: { mapping: { default: @mapping.default, evaluate: @mapping.evaluate, json_paths: @mapping.json_paths, obj_name: @mapping.obj_name, origin: @mapping.origin, other: @mapping.other, target: @mapping.target, type: @mapping.target_type } }
      end

      assert_redirected_to mapping_url(Mapping.last)
    end

    test "should show mapping" do
      get mapping_url(@mapping)
      assert_response :success
    end

    test "should get edit" do
      get edit_mapping_url(@mapping)
      assert_response :success
    end

    test "should update mapping" do
      patch mapping_url(@mapping), params: { mapping: { default: @mapping.default, evaluate: @mapping.evaluate, json_paths: @mapping.json_paths, obj_name: @mapping.obj_name, origin: @mapping.origin, other: @mapping.other, target: @mapping.target, type: @mapping.target_type } }
      assert_redirected_to mapping_url(@mapping)
    end

    test "should destroy mapping" do
      assert_difference('Mapping.count', -1) do
        delete mapping_url(@mapping)
      end

      assert_redirected_to mappings_url
    end
  end
end
