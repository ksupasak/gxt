require 'sinatra'
require 'socket'
require 'sinatra/base'
require 'net/http'
require 'nokogiri'
require 'eventmachine'
set :bind, '0.0.0.0'
set :port, 9300



  get '/' do

      return "OK"

  end

set :queue, []

  post '/export' do


      settings.queue << {:hn=>params[:hn], :admit_id=>params[:admit_id], :host=>"https://localhost:1792", :solution=>params[:solution]}

      return "Export"

  end


EM.next_tick do


EM.add_periodic_timer(1) do

    queue = settings.queue
    # puts queue.size

    if queue.size > 0

    job = queue.shift

    admit_id = job[:admit_id]

    path = '../../tmp'
    
    host = "https://localhost:1792"
    
    host = job[:host] if job[:host]
    
    solution = 'miot'
    solution = job[:solution] if job[:solution]
    
    pcm_path = "#{host}/#{solution}"
    
    filename = "reporttelemedicine_#{job[:hn]}_#{Time.now.strftime("%Y%m%d%H%M%S")}.pdf"

    out_file = "#{File.join(path,filename)}"
 #   cmd = "wkhtmltopdf \"#{pcm_path}/Admit/partial?id=#{admit_id}\" #{out_file}"
    cmd = "python3 gen.py \"#{pcm_path}/Admit/partial?id=#{admit_id}\" #{out_file}"
    puts cmd
    `#{cmd}`


    api_key = "CEH8VH2nAnfxPYYL96nc"

    data = File.open(out_file).read
    
    require "uri"
    require "net/http"
    
    export_status = {}
    
if true

    url = URI("https://wuh.wu.ac.th/uat/api/Ambu/UploadAmbuFile?hn=#{job[:hn]}&filename=#{filename}")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(url)
    request["X-API-KEY"] = api_key
    request["Content-Type"] = "application/pdf"
    request.body = data

    response = https.request(request)
    puts response.read_body
    result = JSON.parse(response.read_body)
    
    export_status[:pdf] = result['responseStatus']
    
end    

if true 
    
    url = URI("https://wuh.wu.ac.th/uat/api/Ambu/UploadAmbuVitalSign")

   
    
    admit_json_uri = URI("#{pcm_path}/Admit/data_json?id=#{admit_id}")
    
    https = Net::HTTP.new(admit_json_uri.host, admit_json_uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    req = Net::HTTP::Get.new(admit_json_uri)
      
    
    json = "{}"
    
    res = https.request(req)
    
    json = res.body 

    admit_data = JSON.parse json
    
    if admit_data['records']
      
      
      records = []
      # {"_id":"63b44178c0a79447047d716d","admit_id":"63b44065c0a79445ef508c42","bmi":null,"bp":"113/75","bp_dia":75,"bp_mean":null,"bp_pr":null,"bp_stamp":"215344","bp_sys":113,"co2":null,"created_at":"2023-01-03T21:53:44.419+07:00","created_user_id":null,"data":null,"eye":null,"glucose":null,"height":null,"hr":69,"motor":null,"note":null,"pr":69,"pupil":null,"rr":20,"score":null,"score_id":null,"send_msg":null,"send_status":null,"sh_visit_id":null,"spo2":98,"stamp":"2023-01-03T21:53:44.418+07:00","station_id":"63b43bcec0a79447047d7050","status":null,"temp":null,"updated_at":"2023-01-03T21:53:44.419+07:00","updated_user_id":null,"verbal":null,"weight":null}]
      height = admit_data['admit']['height']
      weight = admit_data['admit']['weight']
      bmi = admit_data['admit']['bmi']
      
      for i in admit_data['records']
        
        reportDateTime = DateTime.parse(i['stamp']).strftime("%Y%m%d%H%M%S")
        
        record = {:reportDateTime=>reportDateTime, :reportByUID=>i['_id'], :bodyHeight=>height, :bodyWeight=>weight, :bmi=>bmi, 
          :bpSystolic=>i['bp_sys'].to_f, :bpDiastolic=>i['bp_dia'].to_f, :temperature=>i['temp'].to_f, :respirationRate=>i['rr'].to_i, :pulse=>i['pr'].to_i, :o2Sat=>i['spo2'].to_i}
        records << record  
      end
      
      obj = {'hn'=>job[:hn], "vitalSignData"=>records}
        
      
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
 
      request = Net::HTTP::Post.new(url)
      request["X-API-KEY"] = "CEH8VH2nAnfxPYYL96nc"
      request["Content-Type"] = "application/json"
      request.body = JSON.dump(obj)
      puts JSON.dump(obj)
      puts "#{job[:hn]} : #{records.size} records "
      response = https.request(request)
      puts response.read_body
       result = JSON.parse(response.read_body)
       export_status[:vital] = result['responseStatus']
       
    end
    
  end
    
    admit_commit_uri = URI("#{pcm_path}/Admit/data_commit?id=#{admit_id}")
    puts admit_commit_uri    
    https = Net::HTTP.new(admit_commit_uri.host, admit_commit_uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(admit_commit_uri)
    # request["Content-Type"] = "application/json"
    # request.body = JSON.dump(export_status)
    
    status = "ERROR"
    status = "COMPLETED" if export_status[:pdf]['statusCode']=='0000' && export_status[:vital]['statusCode']=='0000'
    
    request.set_form({:admit=>JSON.dump({:export_status=>status,:export_log=>export_status.to_json})})
    response = https.request(request)
    puts response.read_body
    
    # request = Net::HTTP::Post.new(uri,  File.open(out_file).read)

    # form_data = [['body', File.open(out_file).read]] # or File.open() in case of local file
    # form_data = File.open(out_file).read
    # request.body = form_data
     
    # request.set_form form_data, 'multipart/form-data'
    
    # request.set_form form_data
    
    # HTTP.post(URL, body:File.open(out_file))
    
    # request.body = form_data#File.open(out_file).read.to_s
     
    
    # request["X-API-Key"] = 

    # result = http.request(request)
    # puts out_file
    # puts response.inspect
    # puts response.body.inspect
    #




    end

end


end
