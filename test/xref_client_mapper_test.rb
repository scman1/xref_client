require "test_helper"

class XrefClientMapperTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert XrefClient::VERSION
  end

  test "truth" do
    assert_kind_of Module, XrefClient
  end
  
  test "get_obj_mapping" do
      class_name = 'Article'
      object_map = XrefClient::ObjectMapper.get_object_mappings(class_name)
      assert_equal object_map[0].obj_name, class_name
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
  
  def test_get_ror_id
      json_data = {"affiliation"=>[{"id"=>[{"id"=>"https:\/\/ror.org\/00a2xv884","id-type"=>"ROR","asserted-by"=>"publisher"}]}]} 
      json_path = "[['affiliation',0,'id',0,'id']]"
      target_data  = XrefClient::MapJsonToObj.get_inner_element(json_data,eval(json_path))
      assert_equal "https:\/\/ror.org\/00a2xv884", target_data
  end
end
