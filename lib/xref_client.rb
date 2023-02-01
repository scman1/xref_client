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

  #create objects dinamically
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
