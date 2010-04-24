require 'rubygems'
require 'sinatra'
require 'JSON'
require 'vpim'

# /vcard?query=encoded_string
get '/vcard' do
  json = JSON.parse(URI.decode(params[:query]))
  
  # do vcard conversion here
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
      addr.preferred = true
      addr.street = json["adr"]["street-address"]
      addr.locality = json["adr"]["locality"]
      addr.region = json["adr"]["region"]
      addr.postalcode = json["adr"]["postal-code"]
      addr.country = json["adr"]["country-name"]
    end
    
    maker.add_tel(json["tel"])
    
    maker.add_email(json["email"])
  end
  
  content_type 'text/x-vcard'
  send_data card, :filename => 'contact.vcf'
end

get '/vevent' do
  # do vevent conversion here  
end
