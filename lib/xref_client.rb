# lib/xref_client.rb
require 'serrano'
class XrefClient
  def self.getCRData(doi_text)
    begin
        puts "********************************"
        puts "trying to get data from crossref"
        puts "for doi " + doi_text
        puts "********************************"
        
        art_bib = JSON.parse(Serrano.content_negotiation(ids: doi_text, format: "citeproc-json"))
        return art_bib
    rescue
        puts "*********************************"
        puts "failed getting data for " + doi_text
        puts "*********************************"
        return nil
    end
  end
end
