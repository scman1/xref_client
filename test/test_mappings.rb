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
  
  def test_get_authors
    json_data = {"author"=>[{"ORCID"=>"http://orcid.org/0000-0001-8033-303X", "authenticated-orcid"=>false, "given"=>"Hessan", "family"=>"Khalid", "sequence"=>"first", "affiliation"=>[{"name"=>"Nanotechnology and Integrated Bio‐Engineering Centre (NIBEC) Ulster University  Newtownabbey BT37 0QB UK"}]}, {"given"=>"Atta ul", "family"=>"Haq", "sequence"=>"additional", "affiliation"=>[{"name"=>"Nanotechnology and Integrated Bio‐Engineering Centre (NIBEC) Ulster University  Newtownabbey BT37 0QB UK"}]}, {"given"=>"Bruno", "family"=>"Alessi", "sequence"=>"additional", "affiliation"=>[{"name"=>"Nanotechnology and Integrated Bio‐Engineering Centre (NIBEC) Ulster University  Newtownabbey BT37 0QB UK"}]}, {"given"=>"Ji", "family"=>"Wu", "sequence"=>"additional", "affiliation"=>[{"name"=>"Department of Chemistry University of Bath  Claverton Down Bath BA2 7AX UK"}]}, {"given"=>"Cristian D.", "family"=>"Savaniu", "sequence"=>"additional", "affiliation"=>[{"name"=>"School of Chemistry University of St. Andrews  Scotland Fife KY16 9ST UK"}]}, {"given"=>"Kalliopi", "family"=>"Kousi", "sequence"=>"additional", "affiliation"=>[{"name"=>"Department of Chemical and Process Engineering University of Surrey  Guildford Surrey GU2 7XH UK"}]}, {"given"=>"Ian S.", "family"=>"Metcalfe", "sequence"=>"additional", "affiliation"=>[{"name"=>"School of Engineering Newcastle University  Newcastle upon Tyne NE1 7RU UK"}]}, {"given"=>"Stephen C.", "family"=>"Parker", "sequence"=>"additional", "affiliation"=>[{"name"=>"Department of Chemistry University of Bath  Claverton Down Bath BA2 7AX UK"}]}, {"given"=>"John T. S.", "family"=>"Irvine", "sequence"=>"additional", "affiliation"=>[{"name"=>"School of Chemistry University of St. Andrews  Scotland Fife KY16 9ST UK"}]}, {"given"=>"Paul", "family"=>"Maguire", "sequence"=>"additional", "affiliation"=>[{"name"=>"Nanotechnology and Integrated Bio‐Engineering Centre (NIBEC) Ulster University  Newtownabbey BT37 0QB UK"}]}, {"given"=>"Evangelos I.", "family"=>"Papaioannou", "sequence"=>"additional", "affiliation"=>[{"name"=>"School of Engineering Newcastle University  Newcastle upon Tyne NE1 7RU UK"}]}, {"ORCID"=>"http://orcid.org/0000-0003-1504-4383", "authenticated-orcid"=>false, "given"=>"Davide", "family"=>"Mariotti", "sequence"=>"additional", "affiliation"=>[{"name"=>"Nanotechnology and Integrated Bio‐Engineering Centre (NIBEC) Ulster University  Newtownabbey BT37 0QB UK"}]}]}
  end
end
