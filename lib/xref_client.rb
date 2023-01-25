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
