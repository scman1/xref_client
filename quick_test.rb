require './lib/xref_client'
require 'csv'

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
  origin_keys = []
  target_keys = []

  for row in obj_csv_map
    origin_keys.append(row['origin'])
    target_keys.append(row['cdi'])
  end
  # get the origin data to for the target object
  target_values = []
  origin_keys.each {|a_key|
    if a_key == nil
      target_values.append(a_key)
    else
      target_values.append(source_data[a_key])
    end
  }
  target_data = target_keys.zip(target_values).to_h
  # check for defaults, paths and expressions to evaluate before assigning
  obj_csv_map.each do |obj_mapping|
    if not ["NULL","NOT NULL"].include?(obj_mapping['default'])
      # Assing 'default' to 'cdi' attibute using type to cast correctly
      target_data[obj_mapping['cdi']]  = XrefClient::MapJsonToObj.assign_value(obj_mapping['default'],obj_mapping['type'])
    elsif obj_mapping['json_paths'] != nil
      # Get values for 'cdi' attribute from a 'json_path'
      target_data[obj_mapping['cdi']]  = XrefClient::MapJsonToObj.get_inner_element(source_data, eval(obj_mapping['json_paths']))
    elsif obj_mapping['evaluate'] != nil
      # Evaluate an expression to  get values for 'cdi' attribute 
      target_data[obj_mapping['cdi']]  =  XrefClient::MapJsonToObj.evaluate_exp(target_data, obj_mapping['evaluate'])
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
#dois = ['10.1038/s41929-019-0334-3']
class_name='Publication'

dois.each {|doi|
  # get json publication data
  pub_data = XrefClient.getCRData(doi)
  new_pub = map_json_data(pub_mappings_file, pub_data, class_name)

  puts "Title:       " + new_pub.title
  puts "DOI:         " + new_pub.doi
  puts "Year:        " + new_pub.pub_year.to_s
  puts "Year online: " + new_pub.pub_ol_year.to_s
  puts "Year print:  " + new_pub.pub_print_year.to_s
  puts "Journal:     " + new_pub.container_title 
}
