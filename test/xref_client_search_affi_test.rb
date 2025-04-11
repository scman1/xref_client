require "test_helper"

class XrefClientSearchAffiTest < ActiveSupport::TestCase
  def test_affi_search
    affiliation_list = ["UK Catalysis Hub","Korea University Anam Hospital",
                        "Karlsruhe Institute of Technology",
                        "Yantai University"]
    from_date = "2025-01-01"
    until_date = "2025-01-01"
    VCR.use_cassette('affi_search_test') do
      found_dois = XrefClient.findPubsByAffiliation(affiliation_list, from_date, until_date)
      assert_equal 11, found_dois.length
      puts found_dois
    end
  end
end
