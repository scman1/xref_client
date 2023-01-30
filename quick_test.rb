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
def evaluate_exp(target_data, eval_exp)
  # replace 'data_hash' with target_data on the string to evaluate
  # return the evaluate response
  return eval(eval_exp.gsub('d_h', 'target_data'))
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

# check if the class exists
def class_exists?(class_name)
  klass = XrefClient.const_get(class_name)
  return klass.is_a?(Class)
  rescue NameError
    return false
end

# create class if needed
def make_class(class_name, target_keys)
  if not class_exists?(class_name)
    new_class = XrefClient::DigitalObjectFactory.create_class(class_name, target_keys)
  else 
    new_class = XrefClient.const_get(class_name)
  end
  return new_class
end


# map json data to object using mappings file
def map_json_data(mappings_file, source_data, class_name)
  obj_csv_map = read_csv(mappings_file)
  # get the keys for origin and target classes
  xref_keys = []
  target_keys = []

  for row in obj_csv_map
    xref_keys.append(row['xref'])
    target_keys.append(row['cdi'])
  end
  # get the origin data to for the target object
  target_values = []
  xref_keys.each {|a_key|
    if a_key == nil
      target_values.append(a_key)
    else
      target_values.append(source_data[a_key])
    end
  }
  target_data = target_keys.zip(target_values).to_h
  # check for defaults, paths and expressions to evaluate before assigning
  obj_csv_map.each do |xref_mapping|
    if not ["NULL","NOT NULL"].include?(xref_mapping['default'])
      # Assing 'default' to 'cdi' attibute using type to cast correctly
      target_data[xref_mapping['cdi']]  = assign_value(xref_mapping['default'],xref_mapping['type'])
    elsif xref_mapping['json_paths'] != nil
      # Get values for 'cdi' attribute from a 'json_path'
      target_data[xref_mapping['cdi']]  = get_inner_element(target_data, eval(xref_mapping['json_paths']))
    elsif xref_mapping['evaluate'] != nil
      # Evaluate an expression to  get values for 'cdi' attribute 
      target_data[xref_mapping['cdi']]  =  evaluate_exp(target_data, xref_mapping['evaluate'])
      # See other to findout how to get values for 'cdi' attrib
      # map directly: get values for 'cdi' attrib 'xref'attrib
    end
  end
  # create the data object class using the object factory
  target_class = make_class(class_name, target_keys)
  # create an instance of the the target class
  target_obj = target_class.new()
  # assign values to the instance
  XrefClient::DigitalObjectFactory.assign_attributes(target_obj, target_data)
  return target_obj
end 

pub_mappings_file = './map_pub_xref_cdi.csv'
dois = ['10.1016/j.biombioe.2022.106608', '10.1016/j.jcat.2016.05.016','10.1016/j.scitotenv.2022.160480',
        '10.1021/acs.iecr.2c02668', '10.1021/jacs.2c09823', '10.1039/d2gc03234a', '10.1039/d2sc04192h',
        '10.1088/2515-7655/aca9fd', '10.1038/s41929-019-0334-3']
dois = ['10.1002/aenm.202201131', '10.1002/anie.202210748', '10.1021/acs.iecr.2c01930',
        '10.1039/d2cc04701b', '10.1039/d2cy01322c', '10.1039/d2dt02888c', '10.1039/d2fd00119e']
dois = ['10.1038/s41929-019-0334-3']
class_name='Publication'

dois.each {|doi|
  # get json publication data
  pub_data = XrefClient.getCRData(doi)
  new_pub = map_json_data(pub_mappings_file, pub_data, class_name)

  puts "Title:   " + new_pub.title
  puts "DOI:     " + new_pub.doi
  puts "Year:    " + new_pub.pub_year.to_s
  puts "Journal: " + new_pub.container_title 
}
