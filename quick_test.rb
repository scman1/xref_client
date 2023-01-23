require 'serrano'
s_api = Serrano

s_api.configuration do |config|
  config.mailto = "a_nieva@hotmail.com"
end

#puts s_api.works(ids: '10.1371/journal.pone.0033693')

doi = '10.1038/s41929-019-0334-3' #first article in CDI DB
art_bib = JSON.parse(s_api.content_negotiation(ids: doi, format: "citeproc-json"))
puts '*********************************************************************'
puts art_bib
