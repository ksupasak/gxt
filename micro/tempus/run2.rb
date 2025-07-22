require 'net/http'
require 'json'


host = 'https://corsium.info/WebAPI/sdkencr'

uri = URI("#{host}/Account/APILogin")

req = Net::HTTP::Post.new(uri, {'Accept'=>'application/json','Content-Type' =>'application/json'})



p = {}
p['Username'] = "686d4517-bd7f-4b8d-9ece-7a6ce799ad6f"
p['Password'] = "3P(RTe$t1n9"
p['DEM'] = "AES"
p['Key'] = ""


req.body = p.to_json

res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl=>true) {|http|
  http.request(req)
}

puts res.body

result = JSON.parse(res.body)['Data']

# {"ErrorCode":null,"IsSuccessful":true,"DataType":"Real",
#   "Data":{"Access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBRVNLZXkiOiJCSThHM09CSVV4R0IwZmZFeUFucHh4L3MyQ2J0ZWs5S2VwUEw5eGhMWXBBPSIsIkFFU1ZlY3RvciI6ImgwbXAycHIvRnJwb2MxeWtpS1BFN0E9PSIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL25hbWUiOiJzbWFydF9lbXNAY2h1bGEuZ28udGgiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjEuNDcuODcuMzIiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL3VzZXJkYXRhIjoiMiIsIklzUEhJSW5jbHVkZWQiOiIxIiwiSXNERUVuYWJsZWQiOiIxIiwiSXNQYXRpZW50RGVJZGVudGlmaWNhdGlvbkVuYWJsZWQiOiIxIiwiSGlzdG9yaWNBY2Nlc3MiOiIwIiwiRGF0YVR5cGUiOiJSZWFsIiwibmJmIjoxNjk0MTY1OTYwLCJleHAiOjE2OTQxNjc3NjAsImlzcyI6Imh0dHA6Ly9jb3JzaXVtc3VpdGUuY29tIiwiYXVkIjoiY29yc2l1bXN1aXRlLmNvbSJ9.FcMSVoN1ZImuIEjDN36aYUzSKtvXliRyMYvAo0j3UQU",
#     "Token_type":"bearer","Expires_in":1799,
#     "Refresh_token":"73f2cba0-a119-4cdd-b8ea-4cac701e2717",
#     "Algorithm":"AES_256_CBC",
#     "K":"BI8G3OBIUxGB0ffEyAnpxx/s2Cbtek9KepPL9xhLYpA=",
#     "V":"h0mp2pr/Frpoc1ykiKPE7A==",
#     "VersionWebAPI":"2.1.0",
#     "VersionCorsium":"1.10.1.0"},
#     "CRC":"352b"}

# access_token = result['Access_token'].split(".")[0]
# access_token = result['Access_token']
#
#
# uri = URI("#{host}/Account/APIRefreshToken")
#
# req = Net::HTTP::Post.new(uri, {'Accept'=>'application/json','Content-Type' =>'application/json','Authorization'=>"bearer #{access_token}"})
#
# req.each_header {|key,value| puts "#{key} = #{value.inspect}" }
#
#
# puts "Bearer #{access_token}"
#
# puts "Refresh_token #{result['Refresh_token']}"
#
# p = {}
# p['refreshToken'] = result['Refresh_token']
#
#
# req.body = p.to_json
#
# puts p.to_json
#
# res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl=>true) {|http|
#   http.request(req)
# }
#
#
#
# puts res.body


# {"ErrorCode":null,"IsSuccessful":true,"DataType":"Real","Data":{"Access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJBRVNLZXkiOiJYbHRnazZ6enBMOUFJcTJsOGZpK0VhdS9SaHNrY2I2OVFvaXNKd2orNlFBPSIsIkFFU1ZlY3RvciI6IlQ1K1RJcVlVMXBQZ0hEc3pzQVFWNlE9PSIsImh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL25hbWUiOiJzbWFydF9lbXNAY2h1bGEuZ28udGgiLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjE4Mi41Mi41MS4zNCIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvdXNlcmRhdGEiOiIyIiwiSXNQSElJbmNsdWRlZCI6IjEiLCJJc0RFRW5hYmxlZCI6IjEiLCJJc1BhdGllbnREZUlkZW50aWZpY2F0aW9uRW5hYmxlZCI6IjEiLCJIaXN0b3JpY0FjY2VzcyI6IjAiLCJEYXRhVHlwZSI6IlJlYWwiLCJuYmYiOjE2OTQxODU0MTgsImV4cCI6MTY5NDE4NzIxOCwiaXNzIjoiaHR0cDovL2NvcnNpdW1zdWl0ZS5jb20iLCJhdWQiOiJjb3JzaXVtc3VpdGUuY29tIn0.uoU_CmSeHxqAFd98niS4guq-gtGOVmqaJz-elPtUZus","Token_type":"bearer","Expires_in":1799,"Refresh_token":"8f8349dd-02d5-457e-971d-cf2ae3997d3d","Algorithm":"AES_256_CBC","K":"Xltgk6zzpL9AIq2l8fi+Eau/Rhskcb69QoisJwj+6QA=","V":"T5+TIqYU1pPgHDszsAQV6Q==","VersionWebAPI":"2.1.0","VersionCorsium":"1.10.1.0"},"CRC":"2ec5"}
# accept = "application/json"


#
# result = JSON.parse(res.body)['Data']
#
access_token = result['Access_token'].split(".")[0]
access_token = result['Access_token']


uri = URI("#{host}/Api/Organizations")

req = Net::HTTP::Get.new(uri, {'Accept'=>'application/json','Content-Type'=>'application/json','Authorization'=>"bearer #{access_token}"})
# Net::HTTP::Get.new(uri)
req.each_header {|key,value| puts "#{key} = #{value.inspect}" }




res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl=>true) {|http|
  http.request(req)
}

puts res.body

# [{"OrganizationId":"AF24D0CB-DF08-4BB6-A924-E1948E077AED","Name":"King Chulalongkorn Hospital EMS/ER"}]

# {"ErrorCode":null,"IsSuccessful":true,"DataType":"Real","Data":"mZ9+w1a0n+EwMfa0I83h+9KmZeMcriKo0MQkWqMjXsg7tVTKpB8piT/x5gyBvZogGlnpbq6lSn26B4CkmShFvxXADK8xMfb9sQ2/WZc94SyrcYFjHqAHzFRIaYcA5fSa99C/9587MxqHh8Sm9d8MP2sL3K2Q2mgimfJegzolijde8cj2Fz1MtNzDtGjyR0fdcdtR8ibc4kWdJ9+By9Wr7meDAVo0e3NMvoHdrDvfI6th199GW769zzjwXKink0OdRbU/DSLUWLsf5eGxSvPagA==","CRC":"249b"}
