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
  
  test "build_objs" do
      doi = '10.1002/aenm.202201131'
      pub_data = XrefClient.getCRData(doi)
      result_obj = XrefClient::ObjectMapper.map_json_data(pub_data,'Article')
      puts result_obj.to_s
      temp_author_list = pub_data['author']
      temp_author_list.each do |pub_aut|
          new_auth = XrefClient::ObjectMapper.map_json_data(pub_aut, 'ArticleAuthor')
          puts new_auth.to_s
          pub_aut['affiliation'].each do |affi_line|
              new_cr_affi = XrefClient::ObjectMapper.map_json_data(affi_line, 'CrAffiliation')
              puts new_cr_affi.to_s
          end
      end
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
  
  def test_get_authors
    json_data = {"author"=>[{"ORCID"=>"http://orcid.org/0000-0001-8033-303X", "authenticated-orcid"=>false, "given"=>"Hessan", "family"=>"Khalid", "sequence"=>"first", "affiliation"=>[{"name"=>"Nanotechnology and Integrated Bio‐Engineering Centre (NIBEC) Ulster University  Newtownabbey BT37 0QB UK"}]}, {"given"=>"Atta ul", "family"=>"Haq", "sequence"=>"additional", "affiliation"=>[{"name"=>"Nanotechnology and Integrated Bio‐Engineering Centre (NIBEC) Ulster University  Newtownabbey BT37 0QB UK"}]}, {"given"=>"Bruno", "family"=>"Alessi", "sequence"=>"additional", "affiliation"=>[{"name"=>"Nanotechnology and Integrated Bio‐Engineering Centre (NIBEC) Ulster University  Newtownabbey BT37 0QB UK"}]}, {"given"=>"Ji", "family"=>"Wu", "sequence"=>"additional", "affiliation"=>[{"name"=>"Department of Chemistry University of Bath  Claverton Down Bath BA2 7AX UK"}]}, {"given"=>"Cristian D.", "family"=>"Savaniu", "sequence"=>"additional", "affiliation"=>[{"name"=>"School of Chemistry University of St. Andrews  Scotland Fife KY16 9ST UK"}]}, {"given"=>"Kalliopi", "family"=>"Kousi", "sequence"=>"additional", "affiliation"=>[{"name"=>"Department of Chemical and Process Engineering University of Surrey  Guildford Surrey GU2 7XH UK"}]}, {"given"=>"Ian S.", "family"=>"Metcalfe", "sequence"=>"additional", "affiliation"=>[{"name"=>"School of Engineering Newcastle University  Newcastle upon Tyne NE1 7RU UK"}]}, {"given"=>"Stephen C.", "family"=>"Parker", "sequence"=>"additional", "affiliation"=>[{"name"=>"Department of Chemistry University of Bath  Claverton Down Bath BA2 7AX UK"}]}, {"given"=>"John T. S.", "family"=>"Irvine", "sequence"=>"additional", "affiliation"=>[{"name"=>"School of Chemistry University of St. Andrews  Scotland Fife KY16 9ST UK"}]}, {"given"=>"Paul", "family"=>"Maguire", "sequence"=>"additional", "affiliation"=>[{"name"=>"Nanotechnology and Integrated Bio‐Engineering Centre (NIBEC) Ulster University  Newtownabbey BT37 0QB UK"}]}, {"given"=>"Evangelos I.", "family"=>"Papaioannou", "sequence"=>"additional", "affiliation"=>[{"name"=>"School of Engineering Newcastle University  Newcastle upon Tyne NE1 7RU UK"}]}, {"ORCID"=>"http://orcid.org/0000-0003-1504-4383", "authenticated-orcid"=>false, "given"=>"Davide", "family"=>"Mariotti", "sequence"=>"additional", "affiliation"=>[{"name"=>"Nanotechnology and Integrated Bio‐Engineering Centre (NIBEC) Ulster University  Newtownabbey BT37 0QB UK"}]}]}
  end
end
