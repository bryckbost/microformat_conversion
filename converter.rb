require 'rubygems'
require 'sinatra'
require 'json'
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
  attachment "#{json["fn"].downcase.sub(' ', '_')}.vcf"
  card.to_s
end

get '/vevent' do
  # do vevent conversion here  
end
