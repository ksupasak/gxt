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


      settings.queue << {:hn=>params[:hn], :admit_id=>params[:admit_id]}

      return "Export"

  end


EM.next_tick do


EM.add_periodic_timer(1) do

    queue = settings.queue
    puts queue.size

    if queue.size > 0

    job = queue.shift

    admit_id = job[:admit_id]

    path = '../../tmp'

    filename = "reporttelemedicine_#{job[:hn]}_#{Time.now.strftime("%Y%m%d%H%M%S")}.pdf"

    out_file = "#{File.join(path,filename)}"
    cmd = "wkhtmltopdf \"https://localhost:1792/miot/Admit/partial?id=#{admit_id}\" #{out_file}"

    `#{cmd}`


    uri = URI("https://wuh.wu.ac.th/prod/api/Ambu/UploadAmbuFile?hn=#{job[:hn]}&filename=#{filename}")
    uri = URI("https://wuh.wu.ac.th/uat/api/Ambu/UploadAmbuFile?hn=#{job[:hn]}&filename=#{filename}")
    # Full control
    # puts uri
    # http = Net::HTTP.new(uri.host, uri.port)
    # http.use_ssl = true if uri.instance_of? URI::HTTPS
    # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    # http.read_timeout = 300 # seconds
    #
    data = File.open(out_file).read
    #
    # response, body = http.post(uri.path, data, {'X-API-Key'=>'CEH8VH2nAnfxPYYL96nc','Content-Type'=>'binary'})
    #






    require "uri"
    require "net/http"

    url = URI("https://wuh.wu.ac.th/uat/api/Ambu/UploadAmbuFile?hn=61004204&filename=reporttelemedicine_61004204_20221229140540.pdf")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(url)
    request["X-API-KEY"] = "CEH8VH2nAnfxPYYL96nc"
    request["Content-Type"] = "application/pdf"
    request.body = data

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
