require './lib/xref_client'
require 'csv'

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

# return the first val in the path 
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

# get crossref to CDI publications mappings
# 0 xref        the origin crossref attribute
# 1 cdi         the target CDI attribute
# 2 type        the target type
# 3 default     the default value (use type to cast correctly)
# 4 get_it      a list of lists with the json keys to use when drilling down
# 5 evaluate    a expression to use to get the value
# 6 other       notes on how to get data if not specified above
def read_csv(csv_file)
  csv_map = []
  File.open(csv_file) do |file|
    csv_data = CSV.read(file)
    map_headers = csv_data.shift()
    a_mapping = {}
    while row = csv_data.shift()
      a_mapping = map_headers.zip(row).to_h
      csv_map.append(a_mapping)
    end
  end
  return csv_map
end

pub_mappings_file = './map_pub_xref_cdi.csv'

xref_pub_csv_map = read_csv(pub_mappings_file)

# get the keys for origin and target classes

pub_keys = []
xref_keys = []
for row in xref_pub_csv_map
  xref_keys.append(row['xref'])
  pub_keys.append(row['cdi'])
end

# create the CDI publication class using the object factory
cdi_pub_class = XrefClient::DigitalObjectFactory.create_class('Publication', pub_keys)

# get publication data
doi = '10.1038/s41929-019-0334-3'
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

