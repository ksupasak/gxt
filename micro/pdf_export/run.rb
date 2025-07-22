require 'net/http'
require 'json'
require 'fileutils'


base_uri = ARGV[0]

base_uri = "https://localhost:1792/miot/API/ems" unless base_uri

tmp_file = ARGV[1]

tmp_file = "~/Downloads/out.pdf" unless tmp_file

out_path = ARGV[2]

out_path = "~/Documents/" unless out_path



def get_hn hn
  
  if i = hn.index("/")
      
    hn = "#{hn[-2..-1]}#{format("%06d",hn[0..i-1].to_i)}"
      
  end
  
  return hn
  
end

while(true)


# puts get_hn "1234/54"

uri = URI("#{base_uri}?cmd=export.await")


Net::HTTP.start(uri.host, uri.port, :use_ssl => true, :verify_mode=>OpenSSL::SSL::VERIFY_NONE) do |http|
  request = Net::HTTP::Get.new uri
  response = http.request request # Net::HTTPResponse object

  begin

  res = JSON.parse response.body

  if res['code'] == '200 OK'

    list = res['data']

    for i in list

      puts i.inspect

      cmd = `wkhtmltopdf -O Landscape "#{i['url']}" #{tmp_file}`

      hn = i['hn']

      # 62024116_0_18-11-2021_7579500_660301_OPD_Colonoscopy_1.pdf

      date = "#{Time.now.strftime("%d-%m-%Y")}"

      ofilename = "#{get_hn hn}_0_#{date}_9999999_888888_OPD_EMS_1.pdf"

      out_file = File.join(out_path, ofilename)

      # FileUtils.mv(tmp_file, out_file)
      `mv #{tmp_file} #{out_file}`


      uri = URI("#{base_uri}?cmd=export.update&id=#{i['id']}&filename=#{ofilename}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(uri)
      request.add_field('Content-Type', 'application/json')

      # request.body = {'credentials' => {'username' => 'username', 'key' => 'key'}}.to_json
      response = http.request(request)

      puts response.body


    end

  end



rescue Exception=>e
  puts e.inspect
end

  # {"code"=>"200 OK", "data"=>[{"id"=>"64dc8b54f125a37408fe11a6", "export"=>"AwaitExport", "status"=>"Completed", "case_no"=>"EMS-2308-0001", "hn"=>"123456/45", "url"=>"https://localhost:1792/miot/EMS/pdf?id=64dc8b54f125a37408fe11a6"}]}

end

puts Time.now
sleep(10)


end