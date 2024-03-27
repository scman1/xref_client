require "xref_client/engine"

require 'serrano'

module XrefClient
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

  # mappings from json to object using csv file map
  class MapJsonToObj
    # get value from an inner element
    def self.inspect_path(json_vals,a_path)
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
    def self.get_inner_element(json_vals, json_paths)
      ret_val = nil
      json_paths.each do|a_path|
        ret_val = self.inspect_path(json_vals,a_path)
        if ret_val != nil
          break
        end
      end

      return ret_val
    end

    # evaluate a given expression
    def self.evaluate_exp(target_data, eval_exp)
      # replace 'data_hash' with target_data on the string to evaluate
      # return the evaluate response
      return eval(eval_exp.gsub('d_h', 'target_data'))
    end

    def self.only_nums(a_string)
      a_string.scan(/\D/).empty?
    end

    # assign a default value
    def self.assign_value(a_val,a_type)
      if a_type == 'varchar'
         return a_val
      elsif a_type == 'integer'and self.only_nums(a_val)
        return eval(a_val)
      end
      return nil
    end
  end
  class ObjectMapper
    # map json data to object using mappings file
    def self.get_object_mappings(class_name)
      obj_mapping = XrefClient::Mapping.where(obj_name: class_name)
      return obj_mapping
    end
    
    def self.map_json_data(source_data, class_name)
      obj_map = get_object_mappings(class_name)
      # get the keys for origin and target classes
      origin_keys = []
      target_keys = []

      for row in obj_map
        origin_keys.append(row['origin'])
        target_keys.append(row['target'])
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

     publication_data = target_keys.zip(target_values).to_h
      # check for defaults, paths and expressions to evaluate before assigning
      obj_map.each do |obj_mapping|
        if not ["NULL","NOT NULL"].include?(obj_mapping['default'])
          # Assing 'default' to 'cdi' attibute using type to cast correctly
         publication_data[obj_mapping['target']]  = XrefClient::MapJsonToObj.assign_value(obj_mapping['default'],obj_mapping['type'])
        elsif obj_mapping['json_paths'] != nil
          # Get values for 'cdi' attribute from a 'json_path'
         publication_data[obj_mapping['target']]  = XrefClient::MapJsonToObj.get_inner_element(source_data, eval(obj_mapping['json_paths']))
        elsif obj_mapping['evaluate'] != nil
          # Evaluate an expression to  get values for 'cdi' attribute 
         publication_data[obj_mapping['target']]  =  XrefClient::MapJsonToObj.evaluate_exp(publication_data, obj_mapping['evaluate'])
          # See other to findout how to get values for 'cdi' attrib
          # map directly: get values for 'cdi' attrib 'xref'attrib
        end
      end
      
      return publication_data
    end 

  
    # create lists of parameters to three types of CDI objects derived from 
    # crossref: Publication, Article Author and CR Affiliation
    def self.map_xref_to_cdi(source_data)
        result_obj = map_json_data(source_data,'Article')
        temp_author_list = source_data['author']
        aut_count = 1
        authors_list = []
        affis_list = []
        temp_author_list.each do |pub_aut|
            new_auth = map_json_data(pub_aut, 'ArticleAuthor')
            new_auth['author_order'] = aut_count
            authors_list.append(new_auth)
            pub_aut['affiliation'].each do |affi_line|
                new_cr_affi = map_json_data(affi_line, 'CrAffiliation')
                new_cr_affi['article_author_id'] = aut_count
                affis_list.append(new_cr_affi)
            end
            aut_count += 1
        end
        return [result_obj, authors_list, affis_list]
    end
  end

  # create objects dinamically
  class DigitalObjectFactory
    def self.create_class(new_class, *fields)
      c = Class.new do
        fields.flatten.each do |field|
          #replace backslashes and space in names with underscores
          field = field.gsub('/','_')
          field = field.gsub(' ','_')
          define_method field.intern do
            instance_variable_get("@#{field}")
          end
          define_method "#{field}=".intern do |arg|
            instance_variable_set("@#{field}", arg)
          end
        end
      end
      XrefClient.const_set new_class, c
      return c
    end

    def self.assign_attributes(instance, values)
      values.each do |field, arg|
        #replace backslashes and space in names with underscores
          field = field.gsub('/','_')
          field = field.gsub(' ','_')
          instance.instance_variable_set("@#{field}", arg)
      end
    end
  end
end
