require "test_helper"

class XrefClientGetPubTest < ActiveSupport::TestCase

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
    end
  end

  def test_for_no_given_name
    VCR.use_cassette('mononym test') do
      doi = '10.1002/cctc.202100286'
      pub_data = XrefClient.getCRData(doi)
      article_data = XrefClient.getPubDataXRef(pub_data)
      assert_equal "New Spectroscopic Insight into the Deactivation of a ZSM‐5 Methanol‐to‐Hydrocarbons Catalyst", article_data[:title]
      assert_equal article_data[:doi], doi
      assert_equal "Suwardiyanto", article_data[:authors].split(",")[2].strip
      assert_equal "A. Zachariou", article_data[:authors].split(",")[0].strip
    end
  end

  def test_mononym_in_list
    ukch_awards = ["EP/R026939/1", "EP/R026815/1", "EP/R026645/1", "EP/R027129/1",
                   "EP/M013219/1","EP/R026939", "EP/R026815", "EP/R026645",
                   "EP/R027129", "EP/M013219","EP/K014706/2", "EP/K014668/1",
                   "EP/K014854/1", "EP/K014714/1","EP/K014706", "EP/K014668",
                   "EP/K014854", "EP/K014714"]
    from_date = "2025-05-01"
    until_date = "2025-05-23"
    VCR.use_cassette('mononym_in_list_test') do
      found_dois = XrefClient.findPubsAward(ukch_awards, from_date, until_date)
      assert_equal 1, found_dois.length
    end
  end

  def test_for_rubyapp_seeds
    VCR.use_cassette('rubyapp seeds') do
      test_dois = ["10.1101/2025.07.05.663138",
                            "10.26434/chemrxiv-2024-cpjsk", 
                            "10.1021/acsmaterialslett.1c00766"]
      test_dois.each do |t_doi|
        pub_data = XrefClient.getCRData(t_doi)
        assert 1, pub_data.length
        result = XrefClient::ObjectMapper.map_xref_to_cdi(pub_data)
        assert_equal 3, result.length()
        #puts result
      end
    end
  end

  def test_mapping_ror_affiliations
    VCR.use_cassette('ror affiliations') do
      test_dois = ["10.1364/ome.469414",
                   "10.1364/prj.522533"]
      test_dois.each do |t_doi|
        pub_data = XrefClient.getCRData(t_doi)
        assert 1, pub_data.length
        result = XrefClient::ObjectMapper.map_xref_to_cdi(pub_data)
        assert_equal 3, result.length()
        #puts result
      end
    end
  end
end
