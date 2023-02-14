require 'test_helper'

class XrefClient::Test < ActiveSupport::TestCase

  test "truth" do
    assert_kind_of Module, XrefClient
  end

  test "get_cr_data" do
      doi = '10.1038/s41929-019-0334-3'
      pub_data = XrefClient.getCRData(doi)
      assert_equal pub_data['title'], "Tuning of catalytic sites in Pt/TiO2 catalysts for the chemoselective hydrogenation of 3-nitrostyrene"
      assert_equal pub_data['DOI'], doi
  end
  
  test "get_obj_mapping" do
      class_name = 'Article'
      object_map = XrefClient::ObjectMapper.get_object_mappings(class_name)
      assert_equal object_map[0].obj_name, class_name
      #puts object_map.class
  end

  test "build_cdi_ojs" do
      doi = '10.1002/aenm.202201131'
      pub_data = XrefClient.getCRData(doi)
      result = XrefClient::ObjectMapper.map_xref_to_cdi(pub_data)
      assert_equal 3, result.length()
      #puts result
  end

  # assign values test
  def test_assign_value_integer
      a_value = '150'
      value_type = 'integer'
      target_data  = XrefClient::MapJsonToObj.assign_value(a_value,value_type)
      assert_equal 150, target_data
  end

  def test_assign_value_varchar
      a_value = '150'
      value_type = 'varchar'
      target_data  = XrefClient::MapJsonToObj.assign_value(a_value,value_type)
      assert_equal '150', target_data
  end

  def test_fail_assign_value_varchar
      # puts "testing assing value"
      a_value = '150.50'
      value_type = 'integer'
      target_data  = XrefClient::MapJsonToObj.assign_value(a_value,value_type)
      assert_nil target_data
  end

  def test_get_inner_element
    json_data = {'id'=>1, "published"=>{"date-parts"=>[[2022]]}}
    json_path = "[['published','date-parts',0,0]]"
    target_data  = XrefClient::MapJsonToObj.get_inner_element(json_data,eval(json_path))
    assert_equal 2022, target_data
  end

  def test_evaluate_exp
    json_data = {'id'=>1, "pub_ol_year"=>2023, "pub_print_year"=>2022}
    the_exp = "d_h['pub_print_year'] == nil ? (d_h['pub_ol_year']  == nil ? nil : d_h['pub_ol_year'] ) : (d_h['pub_ol_year'] ==nil ? d_h['pub_print_year']  : d_h['pub_print_year']   < d_h['pub_ol_year']  ? d_h['pub_print_year']  : d_h['pub_ol_year'] )"
    target_data  = XrefClient::MapJsonToObj.evaluate_exp(json_data,the_exp)
    assert_equal 2022, target_data
  end
end
