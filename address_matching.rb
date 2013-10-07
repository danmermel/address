require 'open-uri'
require  'json'

# want to get a list of entity pairs
# get some entity info from each (name, address etc)
# do the address matching and add the number to the file as well 

write_to = File.open('uk_match.txt', 'w')
File.open('uk_pairs.txt').each do |line|
    entity_1, entity_2 = line.split(",").each do |ent|
      ent = ent.gsub(/\n/,"")
      puts "xxx#{ent}xx"
      url= 'http://wolf.centralindex.com:80/entity?entity_id='+ent
      puts "trying #{url}"
      page_string = open(url) {|f| f.read}
      parsed = JSON.parse(page_string)
      if parsed["data"].include?("postal_address") then 
       #this is defensive code in case the fields don't exist for the entity address
       parsed["data"]["postal_address"]["address1"].class == String ? (address1 = parsed["data"]["postal_address"]["address1"]):(address1="")
       parsed["data"]["postal_address"]["address2"].class == String ? (address2 = parsed["data"]["postal_address"]["address2"]):(address2="")
       parsed["data"]["postal_address"]["address3"].class == String ? (address3 = parsed["data"]["postal_address"]["address3"]):(address3="")
       parsed["data"]["postal_address"]["district"].class == String ? (district = parsed["data"]["postal_address"]["district"]):(district="")
       parsed["data"]["postal_address"]["town"].class == String ? (town = parsed["data"]["postal_address"]["town"]):(town="")
       parsed["data"]["postal_address"]["county"].class == String ? (county = parsed["data"]["postal_address"]["county"]):(county="")
       parsed["data"]["postal_address"]["province"].class == String ? (province = parsed["data"]["postal_address"]["province"]):(province="")
       parsed["data"]["postal_address"]["postcode"].class == String ? (postcode = parsed["data"]["postal_address"]["postcode"]):(postcode="")
       write_to.write ent +"\t" \
              + parsed["data"]["name"]["name"]+"\t" \
              + address1 +"\t" \
              + address2 +"\t" \
              + address3 +"\t" \
              + district +"\t" \
              + town +"\t" \
              + county +"\t" \
              + province +"\t" \
              + postcode +"\t"
     end  #if     
   end   # each
   #now make the API call to get the distance between the two entitities
   url= 'http://wolf.centralindex.com:80/tools/addressdiff?first_entity_id='+entity_1+'&second_entity_id='+entity_2
   puts "trying #{url}"
   page_string = open(url) {|f| f.read}
   parsed = JSON.parse(page_string)
   #and add it to the file
   write_to.write parsed["data"]["score"].to_s+"\n" 
end

