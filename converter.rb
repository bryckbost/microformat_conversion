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
      if json["n"]
        name.prefix = json["n"]["prefix"] unless json["n"]["prefix"].nil?
        name.given = json["n"]["given-name"][0] unless json["n"]["given-name"].nil?
        name.family = json["n"]["family-name"][0] unless json["n"]["family-name"].nil?
        name.suffix = json["n"]["suffix"] unless json["n"]["suffix"].nil?
        name.additional = json["n"]["additional"] unless json["n"]["additional"].nil?
      end
      name.fullname = json["fn"]
    end

    unless json["adr"].nil? || json["adr"].empty?
      json["adr"].each do |address|
        maker.add_addr do |addr|
          addr.street = address["street-address"] unless address["street-address"].nil?
          addr.locality = address["locality"] unless address["locality"].nil?
          addr.region = address["region"] unless address["region"].nil?
          addr.postalcode = address["postal-code"] unless address["postal-code"].nil?
          addr.country = address["country-name"] unless address["country-name"].nil?
        end
      end
    end

    maker.add_tel(json["tel"][0]["value"]) unless json["tel"].nil?
    maker.add_email(json["email"][0]["value"]) unless json["email"].nil?
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
