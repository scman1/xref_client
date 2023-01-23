require './test/test_helper'

class TestGetpub < Minitest::Test
	# 0 get a publication from crossref
	
	def test_can_get_data
	    VCR.use_cassette('get_cr_data') do
    		doi = '10.1038/s41929-019-0334-3'
	    	pub_data = XrefClient.getCRData(doi)
            assert_equal pub_data['title'], "Tuning of catalytic sites in Pt/TiO2 catalysts for the chemoselective hydrogenation of 3-nitrostyrene"
        end    
	end
    def test_cant_get_data
	    VCR.use_cassette('get_cr_data') do
    		doi = '101038s4192901903343'
	    	pub_data = XrefClient.getCRData(doi)
            assert_nil pub_data
        end    
	end

end
