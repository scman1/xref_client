require './test/test_helper'

class TestMappings < Minitest::Test
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
end
