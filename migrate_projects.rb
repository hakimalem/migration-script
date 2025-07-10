require 'json'
require 'rest-client'

API_URL = 'https://data.earthportal.eu/projects'
API_KEY = 'API_KEY' 

def fetch_old_projects
  response = RestClient.get(API_URL, {accept: :json})
  JSON.parse(response.body)
end

def build_new_project(old)
  {
    "acronym"      => old["acronym"],
    "type"         => "FundedProject",
    "name"         => old["name"],
    "homePage"     => old["homePage"],
    "description"  => old["description"],
    "ontologyUsed" => (old["ontologyUsed"].is_a?(Array) && old["ontologyUsed"].any?) ? old["ontologyUsed"] : ["https://data.earthportal.eu/ontologies/SWEET"],
    "created"      => old["created"],
    "updated"      => old["updated"],
    "keywords"     => [old["acronym"]],
    "contact"      => nil,
    "organization" => nil,
    "grant_number" => nil,
    "start_date"   => nil,
    "end_date"     => nil,
    "funder"       => nil,
    "logo"         => nil,
    "source"       => nil,
    "creator"      => old["creator"]
  }
end

def update_project(new_project, id)
  RestClient.put(
    "#{API_URL}/#{id}",
    new_project.to_json,
    {content_type: :json, accept: :json, Authorization: "apikey token=#{API_KEY}"}
  )
end

# Main migration
old_projects = fetch_old_projects
old_projects.each do |old|
  new_project = build_new_project(old)
  id = old["id"].split('/').last
  begin
    update_project(new_project, id)
    puts "Migrated #{new_project['acronym']}"
  rescue RestClient::ExceptionWithResponse => e
    puts "Failed to migrate #{new_project['acronym']}: #{e.response}"
  rescue => e
    puts "Failed to migrate #{new_project['acronym']}: #{e.message}"
  end
end
