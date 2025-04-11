require "test_helper"

class XrefClientSearchAwardTest < ActiveSupport::TestCase
  def test_award_search
    ukch_awards = ["EP/R026939/1", "EP/R026815/1", "EP/R026645/1", "EP/R027129/1",
                   "EP/M013219/1","EP/R026939", "EP/R026815", "EP/R026645",
                   "EP/R027129", "EP/M013219","EP/K014706/2", "EP/K014668/1",
                   "EP/K014854/1", "EP/K014714/1","EP/K014706", "EP/K014668",
                   "EP/K014854", "EP/K014714"]
    from_date = "2025-01-01"
    until_date = "2025-01-31"
    VCR.use_cassette('award_search_test') do
      found_dois = XrefClient.findPubsAward(ukch_awards, from_date, until_date, funder_list=["10.13039/501100000266"])
      assert_equal 7, found_dois.length
    end
  end
  
  def test_one_award
    ukch_awards = ["EP/M013219/1"]
    from_date = "2025-01-01"
    until_date = "2025-01-31"
    VCR.use_cassette('one_award_test') do
      found_dois = XrefClient.findPubsAward(ukch_awards, from_date, until_date, funder_list=["10.13039/501100000266"])
      assert_equal 1, found_dois.length
    end
  end

  def test_one_formated
    ukch_awards = ["EP/M013219/1"]
    from_date = "2025-01-01"
    until_date = "2025-01-31"
    expected_doi = "10.3390/catal10121370"
    VCR.use_cassette('one_award_test') do
      found_dois = XrefClient.findPubsAward(ukch_awards, from_date, until_date, funder_list=["10.13039/501100000266"])
      assert_equal 1, found_dois.length
      assert found_dois.has_key?(expected_doi)
    end
  end
  # prefer no funder as sometimes the pubs have award but miss funder ID
  def test_no_funder
    ukch_awards = ["EP/R026939/1", "EP/R026815/1", "EP/R026645/1", "EP/R027129/1",
                   "EP/M013219/1","EP/R026939", "EP/R026815", "EP/R026645",
                   "EP/R027129", "EP/M013219","EP/K014706/2", "EP/K014668/1",
                   "EP/K014854/1", "EP/K014714/1","EP/K014706", "EP/K014668",
                   "EP/K014854", "EP/K014714"]
    from_date = "2025-01-01"
    until_date = "2025-01-31"
    VCR.use_cassette('no_funder_test') do
      found_dois = XrefClient.findPubsAward(ukch_awards, from_date, until_date, funder_list=nil)
      assert_equal 8, found_dois.length
    end
  end

  def test_no_funder2
    ukch_awards = ["EP/R026939/1", "EP/R026815/1", "EP/R026645/1", "EP/R027129/1",
                   "EP/M013219/1","EP/R026939", "EP/R026815", "EP/R026645",
                   "EP/R027129", "EP/M013219","EP/K014706/2", "EP/K014668/1",
                   "EP/K014854/1", "EP/K014714/1","EP/K014706", "EP/K014668",
                   "EP/K014854", "EP/K014714"]
    from_date = "2025-01-01"
    until_date = "2025-01-31"
    VCR.use_cassette('no_funder_test') do
      found_dois = XrefClient.findPubsAward(ukch_awards, from_date, until_date)
      assert_equal 8, found_dois.length
    end
  end
end
