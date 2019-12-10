def switch name
  
  settings.set :name, name 
  settings.set :app, settings.apps[name]
  settings.set :context, eval("#{settings.apps[name].gsub('-','_').camelize}")
  MongoMapper.setup({'production' => {'uri' => "mongodb://#{MONGO_HOST}/#{settings.mongo_prefix}-#{settings.name}"}}, 'production')
  
end

# process context 
 
before do 
   
  
  solution_name = DEFAULT_APP
  @prefix_solution = false
  # only   [solution].domain.com
  t = request.host.split(".")
  paths = request.path.split("/")
  
  if paths[1]!='barcode' and paths[1]!='promptpay'
    
  puts "-  Host : #{t.inspect } Path : #{paths.inspect} #{ @default_app.inspect }" 
  
  if  t.size>2  and t[-1].to_i ==0  # detect sub domain 
    @prefix_solution = true
    solution_name = t[0]  # solution_name
    
  elsif t.size==2 and app = settings.apps[paths[1]]
    
    solution_name =  paths[1] if paths[1]
    
  elsif t.size==4 and t[-1].to_i!=0 or request.host=='localhost' # when using ip
    
   solution_name = paths[1] if paths[1]
    
  end
  
  
  # configure solution and user
  
  
  if paths[1]!='__sinatra__' and paths[1]!='favicon.ico'
  
  
  puts "-  Solution Name : #{solution_name}"
  
  # paths = request.path.split("/")
  #   puts paths.inspect 
  #   if paths.size==4 and paths[0]=="" and paths[1].index(".") ==nil 
  #     solution_name = paths[1]
  #   end
  #   \
  settings.set :context, nil
  # if solution_name!='promptpay' and solution_name!='barcode'
  switch solution_name
  # end
  
  # MongoMapper.setup({'production' => {'uri' => "mongodb://#{MONGO_HOST}/#{settings.mongo_prefix}-#{settings.name}"}}, 'production')
  
  
  settings.set :current_user, nil
  settings.set :current_role, nil
  
    
    context = settings.context
    
    
     if settings.context and session[:identity] 
       
       u  = context::User.find session[:identity] 
       
       if u
         @current_user = u.login
         role = context::Role.find u.role
         @current_role = role.name if role
         settings.set :current_user, @current_user
         settings.set :current_role, @current_role
         
       end
       
     end
     
     
   end
   
 end
   
  
end


get '/a/:gxt/:service/*.*' do
  
  
   switch params[:gxt]
   
   
   root = File.dirname(__FILE__)
   settings.set :views, File.join(root, "apps", settings.app ,"views") 
   settings.set :public_folder, File.dirname(__FILE__)+"/public"
   
   require_relative "apps/#{settings.app}/app"
     
     
   file_path,ext = params[:splat]
   
   
   app_public = File.join("apps",settings.app ,"public")
   app_service_public = File.join(app_public,params[:service].downcase)
   gxt_public = File.join("public")
   l = [app_service_public, app_public, gxt_public]
   file = nil
   for i in l
     
     f = File.join(i,"#{file_path}.#{ext}")
     puts "-  Check for #{f}"
     if File.exist? f
      file = f
      break
      end
   end   
     if file     
   send_file file
 end
   # erb :home

end

get '/:service/*.*' do
  
   root = File.dirname(__FILE__)
   settings.set :views, File.join(root, "apps",settings.app ,"views") 
   settings.set :public_folder, File.dirname(__FILE__)+"/public"
   
   require_relative "apps/#{settings.app}/app"
     
     
   file_path,ext = params[:splat]
   
   
   app_public = File.join("apps",settings.app ,"public")
   app_service_public = File.join(app_public,params[:service].downcase)
   gxt_public = File.join("public")
   l = [app_service_public, app_public, gxt_public]
   file = nil
   for i in l
     
     f = File.join(i,"#{file_path}.#{ext}")
     puts "-  Check for #{f}"
     if File.exist? f
      file = f
      break
      end
   end   
   if file   
   send_file file
  end
   # erb :home

end




   # self.class.send :include, GxtFoodOrder
   
   # routing pattern :     /{solution}/Controller/Operation
   
   
def process_request
  
  
   # puts "Process Context : #{ settings.context.inspect }"
  
   self.class.send :include, settings.context
   
   
  
    root = File.dirname(__FILE__)
    settings.set :views, File.join(root, "apps", settings.app  ,"views") 
    settings.set :public_folder, File.dirname(__FILE__)+"/public"

    # load context solution
    require_relative "apps/#{settings.app}/app"

    @context = self

    # Service's class name
    params[:service] = "#{settings.context}::#{params[:service]}"

    puts  params[:service]

   @this = eval "#{params[:service]}Controller.new @context, settings"
   # eval "@this.init"
   @this.setRequest request
  
   # normal web http request
   if !request.websocket?
   
   
     puts 'xxxx '+ params[:operation]
   
   # get content of service
   content = eval "@this.#{params[:operation]} params"
   
   
   return content
   
   else
     
   # web socket request
    
   eval "@this.websocket request"   
      
   request.websocket do |ws|
         ws.onopen do
           # ws.send("Hello World!")
           settings.apps_ws[settings.name] << ws
         end
         ws.onmessage do |msg|
           puts msg
           # 10.times do |i|
           EM.next_tick {  settings.apps_ws[settings.name].each{|s| s.send(msg) } }
           # sleep(1)
           # end
         end
         ws.onclose do
           warn("websocket closed")
            settings.apps_ws[settings.name].delete(ws) 
         end
       end
     end
  
end
   
   
   
get '/:gxt/:service/:operation' do
 process_request
end

post '/:gxt/:service/:operation' do
  process_request
end




get '/:service/:operation' do
  process_request
end


post '/:service/:operation' do
  
  process_request
  
end


get '/barcode' do
  
 
       mode = 'code_128'
       mode = params[:type] if params[:type]
       barcode = nil
       case mode
       when 'code_128'
         barcode = Barby::Code128B.new(params[:code])
       when 'code_39'
         barcode = Barby::Code39.new(params[:code])
       when 'ean_13'
         barcode = Barby::Ean13.new(params[:code])
       when 'qr_code'
         barcode = Barby::QrCode.new(params[:code])
       end
       code = params[:code].split("/").join("-")
       xdim = 2
       xdim = params[:xdim].to_i if params[:xdim]
       xdim = 1 if xdim <1
       height = 50
       height = params[:height].to_i if params[:height]
       height = 30 if height < 30
       margin = 5
       margin = params[:margin].to_i
       # name = File.join("tmp","#{Time.now.to_i}.#{code}.#{mode}.png")
       # File.open(name, 'w'){|f| f.write  }
       content = barcode.to_png :xdim => xdim, :height => height, :margin =>margin
       headers('Content-Type' => "image/jpeg")
       return content
  
end


get '/promptpay' do
  
       total = params[:total]
       
       head = "00020101021129370016A000000677010111"
       acc = params[:acc]
       acc_value = "02#{format('%02d',acc.size)}#{acc}"
       acc_origin = "5802TH"
       total_value = "54#{format('%02d',total.to_s.size)}#{total}"
       tail = "53037646304"
       tag = "#{head}#{acc_value}#{acc_origin}#{total_value}#{tail}".upcase
       sum = CRC.crc('CRC-16-XMODEM', tag ,0xFFFF).to_s(16)
      
       mode = 'qr_code'
       params[:xdim] = 5
       params[:code] = tag+sum
       
       mode = params[:type] if params[:type]
       barcode = nil
       case mode
       when 'code_128'
         barcode = Barby::Code128B.new(params[:code])
       when 'code_39'
         barcode = Barby::Code39.new(params[:code])
       when 'ean_13'
         barcode = Barby::Ean13.new(params[:code])
       when 'qr_code'
         barcode = Barby::QrCode.new(params[:code])
       end
       code = params[:code].split("/").join("-")
       xdim = 2
       xdim = params[:xdim].to_i if params[:xdim]
       xdim = 1 if xdim <1
       height = 50
       height = params[:height].to_i if params[:height]
       height = 30 if height < 30
       margin = 5
       margin = params[:margin].to_i
       # name = File.join("tmp","#{Time.now.to_i}.#{code}.#{mode}.png")
       # File.open(name, 'w'){|f| f.write  }
       content = barcode.to_png :xdim => xdim, :height => height, :margin =>margin
       headers('Content-Type' => "image/jpeg")
       return content
  
end

get '/:gxt' do
   redirect to "/#{params[:gxt]}/Home/index"
end



get '/' do
    if @prefix_solution 
      redirect to "/Home/index"
   else
     redirect to "/#{settings.name}/Home/index"
   
   end
end

