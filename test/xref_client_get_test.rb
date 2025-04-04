require "test_helper"

class XrefClientGetTest < ActiveSupport::TestCase

  test "get_cr_data" do
    VCR.use_cassette('get_cr_data') do
      doi = '10.1038/s41929-019-0334-3'
      pub_data = XrefClient.getCRData(doi)
      assert_equal pub_data['title'], "Tuning of catalytic sites in Pt/TiO2 catalysts for the chemoselective hydrogenation of 3-nitrostyrene"
      assert_equal pub_data['DOI'], doi
    end
  end
  
  # test the mapping of XRef article to CDI object
  test "build_cdi_objs" do
    VCR.use_cassette('build_cdi_objs') do
      doi = '10.1002/aenm.202201131'
      pub_data = XrefClient.getCRData(doi)
      result = XrefClient::ObjectMapper.map_xref_to_cdi(pub_data)
      assert_equal 3, result.length()
      puts result
    end
  end
end
