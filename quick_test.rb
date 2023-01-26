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
# 0 xref		the origin crossref attribute 				
# 1 cdi         the target CDI attribute 
# 2 type        the target type
# 3 default     the default value (use type to cast correctly)
# 4 get_it      a list of lists with the json keys to use when drilling down
# 5 evaluate    a expression to use to get the value
# 6 other       notes on how to get data if not specified above

# get value from an inner element

def inspect_path(json_vals,a_path)
  ret_val = nil
  if json_vals[a_path[0]] != nil 
    if a_path.length() == 1
      ret_val = json_vals[a_path[0]]
    else 
      ret_val = inspect_path(json_vals[a_path[0]],a_path.drop(1))
    end  
  end
  return ret_val  
end 

def get_inner_element(json_vals, json_paths)
  ret_val = nil
  json_paths.each do|a_path|
    ret_val = inspect_path(json_vals,a_path)
    if ret_val != nil
      break
    end
  end
  return ret_val
end

def evaluate_exp(pub_data, eval_exp)
  # replace 'data_hash' with pub_data on the string to evaluate
  # return the evaluate response
  return eval(eval_exp.gsub('d_h', 'pub_data'))
end


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
puts xref_pub_csv_map.to_s


# the new class for the objects:
# get the keys for the cdi pub class:
pub_keys = []
xref_keys = []
for row in xref_pub_csv_map
  xref_keys.append(row[row.keys()[0]])
  pub_keys.append(row[row.keys()[1]])
end

puts pub_keys.to_s
puts xref_keys.to_s
# create the CDI publication class using the object factory
cdi_pub_class = XrefClient::DigitalObjectFactory.create_class('Publication', pub_keys)

pub_data = XrefClient.getCRData(doi)
puts pub_data.to_s

# get crossref data to values for CDI pub_class
xref_pub_values = []
xref_keys.each {|a_key|
  if a_key == nil
    xref_pub_values.append(a_key)
  else
    xref_pub_values.append(pub_data[a_key])
  end
}
xref_pub_data = pub_keys.zip(xref_pub_values).to_h
puts xref_pub_data.to_s

# create an instance of the the CDI publication class
new_pub = cdi_pub_class.new()
# check for defaults, paths and expressions to evaluate before assigning

xref_pub_csv_map.each do |xref_mapping|
  if not ["NULL","NOT NULL"].include?(xref_mapping['default'])
    puts "Assing" + xref_mapping['default'] + " to " +  xref_mapping['cdi'] + " type " + xref_mapping['type']
  elsif xref_mapping['json_paths'] != nil
    puts "Get values for " + xref_mapping['cdi'] + " from " + xref_mapping['json_paths']
    xref_pub_data[xref_mapping['cdi']]  = get_inner_element(pub_data, eval(xref_mapping['json_paths']))
  elsif xref_mapping['evaluate'] != nil
    puts "Evaluate " + xref_mapping['evaluate'] + " to get values for " + xref_mapping['cdi'] 
    xref_pub_data[xref_mapping['cdi']]  =  evaluate_exp(xref_pub_data, xref_mapping['evaluate'])
  elsif xref_mapping['xref'] == nil
    puts "O get values for " + xref_mapping['cdi'] + " from " + xref_mapping['other'].to_s
  else
    puts "X get values for " + xref_mapping['cdi'] + " from " + xref_mapping['xref'].to_s
  end
  puts "current " + xref_pub_data[xref_mapping['cdi']].to_s
end

# assign values to the instance
XrefClient::DigitalObjectFactory.assign_attributes(new_pub, xref_pub_data)

puts new_pub.title
puts new_pub.doi
puts new_pub.pub_year

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

