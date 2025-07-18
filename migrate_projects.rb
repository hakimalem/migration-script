require 'json'
require 'rest-client'

BASE_URL = 'https://datastage.earthportal.eu'
API_URL = "#{BASE_URL}/projects"
API_KEY = '9a3f9f33-f512-4a04-bb84-45636068e255'
BACKUP_FILE = '/home/hakim/Desktop/earthport_projects_backup.json'

def fix_acronym(acronym)
  acronym = acronym.upcase.gsub(/\s+/, '_')
  acronym = acronym.gsub(/[^A-Z0-9_-]/, '')
  acronym
end

def fix_creator_references(creators)
  return [] if creators.nil? || creators.empty?
  
  creators.map do |creator_url|
    if creator_url.include?('/users/')
      username = creator_url.split('/').last
      username
    else
      nil
    end
  end.compact
end

def fix_ontology_references(ontologies)
  return ["#{BASE_URL}/ontologies/SWEET"] if ontologies.nil? || ontologies.empty?
  
  ontologies.map do |ontology_url|
    if ontology_url.include?('/ontologies/')
      ontology_url.gsub("https://data.earthportal.eu", BASE_URL)
    else
      nil
    end
  end.compact
end

def build_new_project(old)
  fixed_acronym = fix_acronym(old["acronym"])
  fixed_creators = fix_creator_references(old["creator"])
  fixed_ontologies = fix_ontology_references(old["ontologyUsed"])

  {
    "acronym"      => fixed_acronym,
    "type"         => "FundedProject",
    "name"         => old["name"],
    "homePage"     => old["homePage"],
    "description"  => old["description"],
    "ontologyUsed" => fixed_ontologies,
    "created"      => old["created"],
    "updated"      => old["updated"],
    "keywords"     => [fixed_acronym],
    "contact"      => old["contacts"],
    "organization" => old["institution"],
    "grant_number" => nil,
    "start_date"   => nil,
    "end_date"     => nil,
    "funder"       => nil,
    "logo"         => nil,
    "source"       => nil,
    "creator"      => fixed_creators
  }
end

def create_project(project)
  begin
    puts "Attempting to create project: #{project['acronym']}..."
    response = RestClient.post(
      API_URL,
      project.to_json,
      {
        content_type: :json, 
        accept: :json, 
        Authorization: "apikey token=#{API_KEY}"
      }
    )
    puts "Created project: #{project['acronym']}"
    return true
  rescue RestClient::ExceptionWithResponse => e
    puts "Failed to create #{project['acronym']}: #{e.response}"
    puts "Project data: #{project.to_json}"
    return false
  rescue => e
    puts "Error creating #{project['acronym']}: #{e.message}"
    return false
  end
end

puts "Loading projects from #{BACKUP_FILE}..."
if File.exist?(BACKUP_FILE)
  projects = JSON.parse(File.read(BACKUP_FILE))
  
  success_count = 0
  fail_count = 0
  
  projects.each do |old_project|
    new_project = build_new_project(old_project)
    
    if create_project(new_project)
      success_count += 1
    else
      fail_count += 1
    end
  end
  
  puts "Creation completed!"
  puts "Successfully created: #{success_count} projects"
  puts "Failed to create: #{fail_count} projects"
else
  puts "Backup file not found: #{BACKUP_FILE}"
end
