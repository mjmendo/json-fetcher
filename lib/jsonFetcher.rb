require "rubygems"
require "json"
require 'net/http'
require 'fileutils'


def get_bla uri
	Net::HTTP.get(uri)
end

def print_to_file filename, what_to_write
	File.open(filename,"w") do |f|
	  f.write(JSON.generate(what_to_write))
	end

end

def create_folders
	#Borra todo el folder con archivos
	FileUtils.rm_rf('staticData')
	#Crea los folders de nuevo
	FileUtils.mkdir_p 'staticData/states'
	FileUtils.mkdir_p 'staticData/gloc'
	FileUtils.mkdir_p 'staticData/dept'
end


module JsonFetcher
	puts "Set up dest folders"
	create_folders()

	puts "Fetching provincias"

	#Provincias
	mainUrl = 'http://54.86.238.56:8080/psearch-indec'
	apis = ['/prov', '/dept', '/gloc']
	select = '/select?q='

	uri = URI(mainUrl + apis[0] + select + '*')
	result = get_bla(uri)
	parsed = JSON.parse(result)
	
	tempHash = {
	    "states" => parsed['response']['docs']
	}

	print_to_file("staticData/states/states.json", tempHash)
	puts "Fetching deptos y municipios"	
	
	#Departamentos
	for prov in parsed['response']['docs']
		
		uri = URI(mainUrl + apis[1] + select + prov['code'].to_s + '*')
		puts "Fetching from: " + uri.to_s
		result = get_bla(uri)
		depts = JSON.parse(result)
		puts "result depts: " + depts.to_s

		deptHash = {
		    prov['code'] => depts['response']['docs']
		}

		filename = prov['code'] + ".json"
		print_to_file("staticData/dept/" + filename, deptHash)
		

		#Municipios
		for dept in depts['response']['docs']
			uri = URI(mainUrl + apis[2] + select + dept['code'].to_s + '*')
			result = get_bla(uri)
			puts "Fetching from: " + uri.to_s
			glocs = JSON.parse(result)

			if dept['code'].to_s.start_with? '06', '02'
				glocs['response']['docs'] = [dept]
			end

			glocHash = {
		    	dept['code'] => glocs['response']['docs']
			}

			filename = dept['code'] + ".json"
			print_to_file("staticData/gloc/" + filename, glocHash)

		end

	end

	
	puts "Fetching terminado"
end



