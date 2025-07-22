# require "google/cloud/speech"
require "google/cloud/speech/v2"
require 'base64'
def transcribe_audio(ogg_file_path)
  
  

  
  # client = Google::Cloud::Speech::V1p1beta1::Speech.speech do |config|
 #    config.credentials = '/Users/soup/Downloads/api-project-129969274551-202e4277b88d.json'
 #  end
  
  client = ::Google::Cloud::Speech::V2::Speech::Client.new do |config|
     config.credentials = '/Users/soup/Downloads/api-project-129969274551-202e4277b88d.json'
    
  end
  

  # audio = client.audio(ogg_file_path,
  #                      encoding: :OGG_OPUS,
  #                      sample_rate_hertz: 16000,
  #                      language: "en-US")
  #
  # response = audio.recognize
  #
  # response.results.each do |result|
  #   puts "Transcript: #{result.transcript}"
  # end


  data = File.open(ogg_file_path).read
  # Encode the puppy
  content = Base64.encode64(data)
  puts content.size

  rconfig = Google::Cloud::Speech::V2::RecognitionConfig.new 
  
  # rconfig.encoding = 'OGG_OPUS'
  # rconfig.sample_rate_hertz =  16000
  
  rconfig.language_code =  ["th-TH",'en-US']

  request = Google::Cloud::Speech::V2::RecognizeRequest.new
  
  request.config = rconfig
  request.content = content

 
  
  # Use a hash to wrap the normal call arguments (or pass a request object), and
  # then add further keyword arguments for the call options.
  response = client.recognize request
  
  p response.inspect

end





ogg_file_path = "ptt.ogg"
transcribe_audio(ogg_file_path)
