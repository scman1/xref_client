require './lib/xref_client'
require 'csv'

def inspect_element(element_name,element_value,element_class)
  if element_class.to_s == "Hash" 
    puts ("* create object: "+ element_name ) 
  elsif element_class.to_s == "Array"
    puts ("* create list of: "+ element_name ) 
  end
end


doi = '10.1038/s41929-019-0334-3'
art_bib = XrefClient.getCRData(doi)

puts '*********************************************************************'
#puts art_bib

File.write('./sample-pub.json', JSON.pretty_generate(art_bib))
class_keys=art_bib.keys()

for a_key in class_keys
  item_class = art_bib[a_key].class()
  puts a_key + ": " + item_class.to_s()  + "\n"
  inspect_element(a_key, art_bib[a_key], item_class)
end

# get crossref data and publications data mappings 

xref_pub_csv = CSV.new('./map_pub_xref_cdi.csv')

xref_pub_csv_map = []

File.open('./map_pub_xref_cdi.csv') do |file|
  xref_pub_csv = CSV.read(file)
  map_headers = xref_pub_csv.shift()
  puts map_headers  
  a_mapping = {}
  while row = xref_pub_csv.shift() 
    a_mapping = map_headers.zip(row).to_h
    xref_pub_csv_map.append(a_mapping)
  end
end 

puts '*********************************************************************'
puts xref_pub_csv_map.length()



# the new class for the objects:
# get the keys for the cdi pub class:
pub_keys = []
for row in xref_pub_csv_map
  pub_keys.append(row[row.keys()[1]])
end

puts pub_keys.to_s

pub_class = XrefClient::DigitalObjectFactory.create_class('Publication', pub_keys)

puts '*********************************************************************'
puts pub_class.class

# get crossref data
pub_data = XrefClient.getCRData(doi)



# fill in publication data
# get authors and link them to article
# get author affiliations and link them to article and 
    def getPubData(db_article, doi_text)
      if doi_text != ""
        # need to raise an exeption if doi is incorrect or no data is returned
        # need to check the doi is not in DB before saving (lower and uppercase versions)
        # need to trim dois before saving
        pub_data = XrefClient.getCRData(doi_text)
        data_keys = pub_data.keys()
        pub_columns = []
        exclude_columns = get_excluded()
        for key in data_keys do
          key_cp = key.dup()
          if not pub_columns.include?(key_cp) and not exclude_columns.include?(key_cp)
            pub_columns.append(key_cp)
          end
        end
        for key in pub_columns
          key_cp = key.dup()
          if key_cp.include?('-')
            new_key = key_cp.gsub('-','_')
            pub_columns.delete(key_cp)
            pub_columns.append(new_key)
            pub_data[new_key] = pub_data[key]
            pub_data.delete(key_cp)
          end
        end
        for frzkey in ['container-title', 'journal-issue']
          pub_columns.delete(frzkey)
          new_key = frzkey.gsub('-','_')
          pub_columns.append(new_key)
          pub_data[new_key] = pub_data[frzkey]
          pub_data.delete(frzkey)
        end
        puts "###################################################################"
        puts pub_columns
        puts pub_data
        puts "###################################################################"
        puts pub_data['title']
        db_article.title = pub_data['title']
        db_article.publisher = pub_data['publisher']
        db_article.issue = pub_data['issue']
        db_article.pub_type = pub_data['type']
        db_article.license = pub_data['license']
        db_article.volume = pub_data['volume']
        db_article.referenced_by_count = pub_data['is_referenced_by_count']
        db_article.references_count = pub_data['references_count']
        db_article.link = pub_data['link']
        db_article.url = pub_data['URL']
        if pub_data.keys.include?('journal_issue') \
          and pub_data['journal_issue'] != nil then
          if pub_data['journal_issue'].keys.include?('issue') then
            db_article.journal_issue = pub_data['journal_issue']['issue']
          end
          if pub_data['journal_issue'].keys().include?('published-print') then
            if pub_data['journal_issue']['published-print']['date-parts'][0].length == 1 then
              #assume that if date parts has only one element, it is year
              db_article.pub_ol_year = pub_data['journal_issue']['published-print']['date-parts'][0][0]
            elsif pub_data['journal_issue']['published-print']['date-parts'][0].length == 2 then
              #assume that if date parts has two elements, they are year and month
              db_article.pub_ol_year = pub_data['journal_issue']['published-print']['date-parts'][0][0]
              db_article.pub_ol_month = pub_data['journal_issue']['published-print']['date-parts'][0][1]
            elsif pub_data['journal_issue']['published-print']['date-parts'][0].length == 3 then
              # assume year, month and day if date parts has three elements
              db_article.pub_print_year = pub_data['journal_issue']['published-print']['date-parts'][0][0]
              db_article.pub_print_month = pub_data['journal_issue']['published-print']['date-parts'][0][1]
              db_article.pub_print_day = pub_data['journal_issue']['published-print']['date-parts'][0][2]
            end
          end
        end
        db_article.container_title = pub_data['container_title']
        db_article.page = pub_data['page']
        db_article.abstract = pub_data['abstract']
        if pub_data.keys.include?('published_online') then
          if pub_data['published_online']['date-parts'][0].length == 1 then
            #assume that if date parts has only one element, it is year
            db_article.pub_ol_year = pub_data['published_online']['date-parts'][0][0]
          elsif pub_data['published_online']['date-parts'].length == 2 then
            #assume that if date parts has two elements, they are year and month
            db_article.pub_ol_year = pub_data['published_online']['date-parts'][0][0]
            db_article.pub_ol_month = pub_data['published_online']['date-parts'][0][1]
          elsif pub_data['published_online']['date-parts'][0].length == 3 then
            # assume year, month and day if date parts has three elements
            db_article.pub_ol_year = pub_data['published_online']['date-parts'][0][0]
            db_article.pub_ol_month = pub_data['published_online']['date-parts'][0][1]
            db_article.pub_ol_day = pub_data['published_online']['date-parts'][0][2]
          end
        end
        if pub_data.keys.include?('published_print') then
          if pub_data['published_print']['date-parts'][0].length == 1 then
            #assume that if date parts has only one element, it is year
            db_article.pub_ol_year = pub_data['published_print']['date-parts'][0][0]
          elsif pub_data['published_print']['date-parts'][0].length == 2 then
            #assume that if date parts has two elements, they are year and month
            db_article.pub_ol_year = pub_data['published_print']['date-parts'][0][0]
            db_article.pub_ol_month = pub_data['published_print']['date-parts'][0][1]
          elsif pub_data['published_print']['date-parts'][0].length == 3 then
            # assume year, month and day if date parts has three elements
            db_article.pub_print_year = pub_data['published_print']['date-parts'][0][0]
            db_article.pub_print_month = pub_data['published_print']['date-parts'][0][1]
            db_article.pub_print_day = pub_data['published_print']['date-parts'][0][2]
          end
        end
        if db_article.pub_ol_year != nil
          db_article.pub_year = db_article.pub_ol_year
        else
          db_article.pub_year = db_article.pub_print_year
        end
      end
      # mark incomplete as it is missing authors, affiliation and themes
      db_article.status = "Incomplete"
    end

