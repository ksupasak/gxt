require 'googleauth'
require 'net/http'
require 'uri'
require 'json'

def send_firebase_notification project_id, token, title, body, cmd, cmd_value
  # Path to your service account JSON key file
  service_account_file = '../keys/smart-ems.json'

  # Authenticate with the service account
  scope = 'https://www.googleapis.com/auth/firebase.messaging'
  authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
    json_key_io: File.open(service_account_file),
    scope: scope
  )
  access_token = authorizer.fetch_access_token!['access_token']

  # FCM API endpoint (v1)
  uri = URI.parse('https://fcm.googleapis.com/v1/projects/'+project_id+'/messages:send')
  
  # Notification payload
  payload = {
    message: {
      notification: {
        title: title,
        body: body,
      },
      "android": {
           "notification": {
             "channel_id": "alert-ems",
             "sound": "warning" 
           }
         },
      "data":{
        cmd: cmd,
        cmd_value: cmd_value,
        
      },
      token: token # Replace with the target device token
    }
  }

  # HTTP POST request
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.path, {
    'Content-Type': 'application/json',
    'Authorization': "Bearer #{access_token}"
  })

  request.body = payload.to_json

  # Send request and handle response
  response = http.request(request)
  puts "Response code: #{response.code}"
  puts "Response body: #{response.body}"
end

# Call the function
# send_firebase_notification 'smart-ems-6dbe1', 'dYxuEu92S5K6AcNZmETCx_:APA91bGDW-wbkWJPlXrHLFJxB33vaCLRSgk881aGWRamnjWlWOxb7A8iLbMBfS96nctIUlf6GlSIBVX-1QPaWmbRv7Y2YXyT16twFDx2gAkw9yCMzj8DgP4', "SmartEMS", "test-push", "meeting", "test"