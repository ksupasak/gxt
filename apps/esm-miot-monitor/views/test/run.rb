require 'sinatra'
require 'json'
require 'net/http'
require 'uri'
require 'puma'

# Define the Bearer token (replace with a secure token in production)
BEARER_TOKEN = "e86d349c83bc7b9db3d2b488fb0f0021"

# Define the allowed IP whitelist
IP_WHITELIST = ["127.0.0.1", "103.20.120.53"]

# Configure Sinatra to use Puma as the server and bind to a specific IP and port
configure do
  set :server, :puma
  set :bind, '0.0.0.0'  # Bind to all available IPs
  set :port, 4567       # Default port
end

# Before filter to enforce IP whitelist
before do
  client_ip = request.ip
  unless IP_WHITELIST.include?(client_ip)
    halt 403, { statuscode: 403, statusmessage: "Forbidden: IP not allowed" }.to_json
  end
end

# Root route
get '/' do
  "Hello, World!"
end

# Route to serve the JSON document
get '/patient_data' do
  # Check Authorization header for Bearer token
  auth_header = request.env['HTTP_AUTHORIZATION']
  if auth_header.nil? || !auth_header.start_with?('Bearer ')
    halt 401, { statuscode: 401, statusmessage: "Unauthorized" }.to_json
  end

  token = auth_header.split(' ').last
  unless token == BEARER_TOKEN
    halt 403, { statuscode: 403, statusmessage: "Forbidden" }.to_json
  end

  # JSON response
  content_type :json
  {
    statuscode: 200,
    statusmessage: "Get Patient Success!",
    data: {
      hn: "11111",
      cid: "1111111111111",
      prefix_name: "นาย",
      fname: "น้ำเพชร",
      lname: "บุญส่ง",
      prefix_en: "",
      fname_en: "TEST",
      lname_en: "TEST",
      birth_date: "2005-23-05",
      gender: "F",
      patient_phone: "0528455301",
      contact_phone: "0639798225",
      address: "90/74 xxxx xxxx xxxx xxx ",
      nationality: "ไทย",
      img: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wcAAwAB/0p8qOUAAAAASUVORK5CYII="
    },
    processed_at: "2025-01-20T02:43:37.268800"
  }.to_json
end

# Proxy route to fetch patient info from another server
get '/api/getPatientInfo' do
  # Check Authorization header for Bearer token
  auth_header = request.env['HTTP_AUTHORIZATION']
  if auth_header.nil? || !auth_header.start_with?('Bearer ')
    halt 401, { statuscode: 401, statusmessage: "Unauthorized" }.to_json
  end

  token = auth_header.split(' ').last
  unless token == BEARER_TOKEN
    halt 403, { statuscode: 403, statusmessage: "Forbidden" }.to_json
  end

  # Validate query parameter
  hn = params['hn']
  if hn.nil? || hn.empty?
    halt 400, { statuscode: 400, statusmessage: "Bad Request: Missing or invalid 'hn' parameter" }.to_json
  end

  # Make request to another server with Bearer token
  uri = URI("http://localhost:4567/api/getPatientInfo?hn=#{hn}")
  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Get.new(uri)
  request['Authorization'] = "Bearer #{BEARER_TOKEN}"

  response = http.request(request)

  # Return the response from the other server
  status response.code.to_i
  content_type :json
  response.body
end

# Error handling for other routes
not_found do
  content_type :json
  { statuscode: 404, statusmessage: "Not Found" }.to_json
end
