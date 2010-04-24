require 'rubygems'
require 'sinatra'
require 'json'
require 'vpim/vcard'
require 'ri_cal'

get '/' do
  "GET to /vcard?query or /vevent?query"
end

# /vcard?query=encoded_string
get '/vcard' do
  json = JSON.parse(URI.decode(params[:query]))
  
  card = Vpim::Vcard::Maker.make2 do |maker|
    maker.add_name do |name|
      name.prefix = json["n"]["prefix"] unless json["n"]["prefix"].nil?
      name.given = json["n"]["givenName"] unless json["n"]["givenName"].nil?
      name.family = json["n"]["familyName"] unless json["n"]["familyName"].nil?
      name.suffix = json["n"]["suffix"] unless json["n"]["suffix"].nil?
      name.additional = json["n"]["additional"] unless json["n"]["additional"].nil?
      name.fullname = json["fn"]
    end

    maker.add_addr do |addr|
      addr.street = json["adr"][0]["street-address"]
      addr.locality = json["adr"][0]["locality"]
      addr.region = json["adr"][0]["region"]
      addr.postalcode = json["adr"][0]["postal-code"]
      addr.country = json["adr"][0]["country-name"]
    end
    
    maker.add_tel(json["tel"].first)
    maker.add_email(json["email"].first)
  end
  
  content_type "text/x-vcard"
  attachment "#{json["fn"].downcase.gsub(' ', '_')}.vcf"
  card.to_s
end

#/vevent?query=encoded_string
get '/vevent' do
  json = JSON.parse(URI.decode(params[:query]))
  
  content_type "text/calendar"
  attachment "#{json["summary"].downcase.gsub(' ', '_')}.ics"
  RiCal.Calendar do
    event do
      summary     json["summary"] unless json["summary"].nil?
      description json["description"] unless json["description"].nil?
      dtstart     DateTime.parse(json["dtstart"]) unless json["dtstart"].nil?
      dtend       DateTime.parse(json["dtend"]) unless json["dtend"].nil?
      location    json["location"] unless json["location"].nil?
      url         json["url"] unless json["url"].nil?
    end
  end.to_s
end
