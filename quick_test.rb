require './lib/xref_client'

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


