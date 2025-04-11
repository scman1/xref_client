require "xref_client/version"
require "xref_client/engine"
require 'serrano'
module XrefClient
  def self.getCRData(doi_text)
    begin
        art_bib = JSON.parse(Serrano.content_negotiation(ids: doi_text, format: "citeproc-json"))
        return art_bib
    rescue => e
        puts "failed getting data for " + doi_text
        "Exception: #{e.message}"
        return nil
    end
  end

  def self.findPubsAward(award_list, date_from, date_to,funder_list=nil)
    collected_dois = {}
    for an_award in award_list do
      if funder_list
        art_bib = Serrano.works(filter: {has_funder: true,
                                       award_funder: funder_list,
                                       award_number:[an_award],
                                       from_deposit_date: date_from,
                                       until_deposit_date: date_to},
                                       format: "citeproc-json")
      else
        art_bib = Serrano.works(filter: {has_funder: true,
                                       award_number:[an_award],
                                       from_deposit_date: date_from,
                                       until_deposit_date: date_to},
                                       format: "citeproc-json")
      end
      if art_bib["message"]["items"].count()>0
        results=art_bib["message"]["items"]
        for a_result in results do
          if collected_dois.has_key?(a_result["DOI"])
            collected_dois[a_result["DOI"]][:awards].append(an_award)
          else
            a_pub = getPubDataXRef(a_result)
            a_pub[:awards] = [an_award]
            a_pub[:cut_date] = date_to
            collected_dois[a_result["DOI"]] = a_pub
          end
        end
      end
    end
    return collected_dois
  end

  def self.findPubsByAffiliation(group_size = 100, affiliation_synonyms=["UK Catalysis Hub"], date_from, date_to)
    cursor = "*"
    found_pubs = {}
    accumulated = 0
    loop do
      json_pages = getJSONbatch(cursor, group_size, date_from, date_to)
      break if json_pages.empty?
      cursor = json_pages[0]["message"]["next-cursor"]
      expected_results = json_pages[0]["message"]["total-results"]
      accumulated += json_pages.count * 20  # Assuming page size is 20
      filtered_pubs = filterJSONResults(json_pages, affiliation_synonyms, date_to)
      found_pubs.merge!(filtered_pubs)
      # break when remaining is less than group_size
      break if (expected_results - accumulated) < group_size || cursor.nil?
    end
    found_pubs
  end

  def self.getJSONbatch(a_cursor = "*", batch_size = 1000, date_from, date_to)
    begin
      response = Serrano.works(filter: {has_affiliation: true,
                                        from_deposit_date: date_from,
                                        until_deposit_date: date_to},
                               cursor: a_cursor,
                               cursor_max: batch_size,
                               format: "citeproc-json")
    rescue => e
      puts "Could not get data using cursor"
      puts "Exception: #{e.message}"
    end
    response
  end
  
  def self.filterJSONResults(pages, affiliation_synonyms, date_to)
    collected_dois = {}
    pages&.each do |art_bib|
      results = art_bib["message"]["items"]
      next if results.nil? || results.empty?
      results.each do |a_result|
        authors = a_result["author"]&.compact || []
        next if authors.empty?
        affi_found = false
        affi_str = ""
        authors.each do |an_author|
          affiliations = an_author["affiliation"]&.reject(&:empty?) || []
          next if affiliations.empty?
          affiliations.each do |affi_line|
            begin
              this_affi_line_sucks = affi_line.to_s
              affi_found = affiliation_synonyms.any? do |an_affi|
                if affi_line["name"].include?(an_affi)
                  affi_str = an_affi
                  break true
                end
              end
            rescue => e
              puts "+" * 50
              puts "Affiliation line: #{this_affi_line_sucks}"
              puts "Exception: #{e.message}"
              # Unmanaged ROR causes an exception
              # {"id"=>[{"id"=>"https://ror.org/02s9jxg24", "id-type"=>"ROR", "asserted-by"=>"publisher"}]}
            end
            if affi_found
              a_pub = getPubDataXRef(a_result)
              a_pub[:xref_affi] = affi_str
              a_pub[:cut_date] = date_to
              collected_dois[a_result["DOI"]] = a_pub
              break
            end
          end
        end
      end
    end
    collected_dois
  end

  # This method uses the mapper to parse JSON data to be returned
  def self.getPubDataXRef(json_data)
    data_mappings = XrefClient::ObjectMapper.map_xref_to_cdi(json_data)
    # json_data has three lists:
    # 0 - Article
    # 1 - Authors
    # 2 - Affiliations
    # need to get author names abreviated here
    authors_list = getAuthorsList(data_mappings[1])
    bib_data = {authors: authors_list, year: data_mappings[0]["pub_year"],
                title: data_mappings[0]["title"].join(" "),
                doi: data_mappings[0]["doi"]}
  end

  def self.getAuthorsList(authors)
    disp_names = ""
    authors.each do|auth|
      # Normalize accents
      pr_name = auth["given_name"].unicode_normalize(:nfd).gsub(/\p{M}/, '')

      # Format name with initials
      pr_name = pr_name.gsub(/\w+/){|s| "#{s[0].upcase}. "}
                       .sub(/\w+\z/, &:capitalize)
                       .gsub(' .',' ')

      this_name = pr_name + auth["last_name"]

      disp_names = disp_names.empty? ? this_name : "#{disp_names}, #{this_name}"
    end
    return disp_names
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
