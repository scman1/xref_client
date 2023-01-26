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

# evaluate a given expression
def evaluate_exp(pub_data, eval_exp)
  # replace 'data_hash' with pub_data on the string to evaluate
  # return the evaluate response
  return eval(eval_exp.gsub('d_h', 'pub_data'))
end

def only_nums(a_string)
  a_string.scan(/\D/).empty?
end

# assign a default value
def assign_value(a_val,a_type)
  if a_type == 'varchar'
     return a_val
  elsif a_type == 'integer'and only_nums(a_string)
    return eval(a_val)
  end
  return nil
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
    xref_pub_data[xref_mapping['cdi']]  = assign_value(xref_mapping['default'],xref_mapping['type'])
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
puts new_pub

