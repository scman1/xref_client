require "test_helper"

class XrefClientCRErrorTest < ActiveSupport::TestCase
  def test_get_error_from_get_doi_data
    VCR.use_cassette("get_cr_data_error") do
      test_dois = ['10.1039/d2cc01785g', '10.1039/d5cy00336a', 
          '10.1039/d0sc01924k', '10.1039/d2su00082b', '10.1039/d4lf00230j',
          '10.1039/d1cy00048a', '10.1039/d4cp03761h', '10.1039/d2gc03234a',
          '10.1016/j.apcatb.2025.125029', '10.1016/j.cej.2026.175992',
  	  '10.1039/d4ey00044g', '10.1039/d2cy02154d', '10.1039/d3cs00468f',
  	  '10.1039/d5ma00666j','10.1016/j.sbi.2020.12.015','10.1039/d2fd00119e',
  	  '10.1016/j.susc.2024.122620','10.1039/d2cc04701b',
  	  '10.1016/j.jcat.2024.115696', '10.1039/d4cy00602j',
  	  '10.1039/d4cc06209d', '10.1039/d2fd00148a', '10.1039/d1ta01464a',
          '10.1039/d1fd00004g', '10.1039/d0ta08351h', '10.1039/d2dd00105e',
          '10.1016/j.cell.2021.04.001', '10.1039/d2cy01322c',
          '10.1039/d4re00181h', '10.1016/j.jcou.2025.103220',
          '10.1016/j.apcata.2022.118817', '10.1039/d5cp03860j',
          '10.1039/d1gc04414a', '10.1039/d4ey00026a','10.1039/d3cy01064c',
          '10.1039/d1cy02001c', '10.1039/d0cy00036a', '10.1039/d2cy01299e',
          '10.1039/d0gc02295k', '10.1039/d1ee03523a', '10.1039/d0cy02164d',
          '10.1039/d3sc05105f','10.1039/d2py00189f', '10.1039/d2nr02014a',
          '10.1039/d3cy01046e', '10.1039/d4re00449c','10.1039/d3sc05516g',
          '10.1039/d4sc02051k', '10.1039/d2sc02752f', '10.1039/c8cc07444e',
          '10.1039/c7dt01022b',
          '10.1039/c6cp01209d', '10.26434/chemrxiv-2021-bv7tb-v2', '10.1039/c6cp01160h','10.1039/d0cy01608j',
          '10.1039/c6cp01494a', '10.1039/d0ob02566f', '10.26434/chemrxiv-2021-bv7tb','10.1039/c8ta12263f',
          '10.1039/d0cc02520h','10.1039/c7fd00210f', '10.1039/d0sc03113e','10.1039/c7dt03395h',
          '10.1039/d1gc01852c','10.1098/rsta.2020.0056', '10.1039/d0ta01398f','10.1039/c9nr04553h',
          '10.1002/anie.202419923','10.1039/c9cy02371b', '10.1039/c9cy02473e','10.1039/d1cp00979f',
          '10.1039/d1gc00901j','10.1039/c7fd00221a', '10.1039/c9cy01679a','10.1039/c8cc01880d',
          '10.1039/d0cp01196g','10.1039/c8nj03632b', '10.1039/c9cp00826h','10.1039/c9na00159j',
          '10.1039/c5cc06118k','10.1039/d1fd00121c', '10.1039/c6nr00053c','10.1039/c9dt03590g',
          '10.1039/c5ta10283a','10.1039/c9dt00595a', '10.1039/c5fd00225g','10.1039/d0cp00793e',
          '10.1039/c7fd00216e','10.1039/d0cp01227k', '10.1039/c6fd00189k','10.1016/j.jaap.2025.107542',
          '10.1039/c8cp02381f','10.1039/c7cy00965h', '10.1039/d2sc04192h','10.1039/c9cp03934a',
          '10.1039/c9dt00228f','10.1039/c8dt05051a', '10.1039/c7dt04805j','10.1021/acscatal.6c03027']
      # this is not triggering the error the time it takes for the api to reply does not trigger the 429. Only cursor does.
      # need to test directly on serrano
      puts "testing this get CR data error"
      test_dois.each do |t_doi|
        pub_data = XrefClient.getCRData(t_doi)
        assert 1, pub_data.length
        #result = XrefClient::ObjectMapper.map_xref_to_cdi(pub_data)
        #assert_equal 3, result.length()
        #puts result
      end
    end
  end

  def test_award_search_error
    ukch_awards = ["EP/R026939/1", "EP/R026815/1", "EP/R026645/1", "EP/R027129/1",
                   "EP/M013219/1","EP/R026939", "EP/R026815", "EP/R026645",
                   "EP/R027129", "EP/M013219", "EP/K014706/2", "EP/K014668/1",
                   "EP/K014854/1", "EP/K014714/1", "EP/K014706", "EP/K014668",
                   "EP/K014854", "EP/K014714", "UKRI945","UKRI-945","UKRI 945"]
    from_date = "2026-01-01"
    until_date = "2026-05-31"
    puts "testing award search error"
    
    VCR.use_cassette('award_search_error') do
      puts "inside VCR"
      found_dois = XrefClient.findPubsAward(ukch_awards, from_date, until_date, funder_list = nil, cr_wait=false)
      puts found_dois
      assert_equal 2, found_dois.length
    end
  end

end
