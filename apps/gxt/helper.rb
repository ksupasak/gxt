require 'barby'
require 'barby/barcode/code_128'
require 'barby/barcode/ean_13'
require 'barby/barcode/code_39'
require 'barby/barcode/qr_code'
require 'barby/outputter/png_outputter'


def register_app name, application, extended=nil
  settings.apps[name] = application
  settings.apps_ws[name] = []
  settings.apps_rv[application] = [] unless  settings.apps_rv[application]
  settings.apps_rv[application] << name
  # settings.extended[application] = extended if extended

end



def add_module path, name, mname=nil
  
  require_relative "#{path}/modules/#{name}/controller"
  if mname
    m =  eval(mname)
    # include m 
    
    # init
    
  end
  
    
end



helpers do
  def username
    session[:identity] ? session[:identity] : '-'
  end
  
  def current_user
    settings.current_user ? settings.current_user : '-'
  end
  
  def current_role
    settings.current_role ? settings.current_role : '-'
  end
  
  
  def link_to name, url, options=nil
    
      if options 
       opt = []
       options.each_pair do |k,v|
        opt << "#{k}='#{v}'"
       end
       opt = opt.join(" ")
       end
    class_opt = ''
    class_opt = "class='#{options[:class]}'" if options and options[:class]
    
    "<a href='#{url.html_safe}' #{class_opt} #{opt}>#{name}</a>"
  end
  
  def fn num
    s = n
    
  end
  
  def image_id_tag att_id, options=nil
     att = Attachment.find(att_id)
     opt = ""
     if options 
     opt = []
     options.each_pair do |k,v|
      opt << "#{k}='#{v}'"
     end
     opt = opt.join(" ")
     end
     
     if att
       "<img src='../Attachment/content?id=#{att.id}' #{opt}>"
     end
  end
  
  def form_for name, url, &block
    
      return block
      
      
  end
  
  def text_field_tag name, value, options={}
      
      "<input name='#{name}' type='text' value='#{value}' #{options.collect{|k,v| "#{k}='#{v}'" }.join(" ")} />"
  end
  
  
  def redirect_to url, delay=0
    '<meta http-equiv="refresh" content="'+delay.to_s+'; url='+url+'" />'
  end
  
  def url_for url
    "/#{settings.name}/#{url}"
  end
  
  def view v
      settings.app
  end
  
  def data_field model
      
      
      keys = model.keys
      res = keys
      res = keys.collect{|k| k if k[0].!='created_at' and k[0].!='updated_at' and k[0][0]!='_'}.compact
    
      return res
    
  end
  
  def solve this, p
    
    
    path = :"#{params[:service].split(':').underscore}/#{p}"
    # puts "test #{File.join("#{path}.erb")}"
    unless FileTest.exist? File.join(settings.views,"#{path}.erb")
      path = File.join("..","..", "gxt" ,"views", "document", p.to_s) 
    end
    path
    
  end
  
  def send_all msg
    EM.next_tick {  settings.apps_ws[settings.app].each{|s| s.send(msg) } }
  end
  
  def inline this, p
    
    
    path = :"#{params[:service].split(':')[-1].underscore}/#{p}"
    # puts "test #{File.join("#{path}.erb")}"
    unless FileTest.exist? File.join(settings.views,"#{path}.erb")
      path = File.join("..","..", "gxt" ,"views", "document", p.to_s) 
    end
    path
    
    partial path, :locals=>{:this=>this}
    
  end
  
  
  
end


class GXT 

  
attr_accessor :request  
  
def setRequest request
  puts request
   @request
end  

def request 
   return @request
end
  
def initialize context, settings
    @context = context
    @settings =  @context.settings
end  

def controller
  "#{self.class.name.gsub("Controller","").split(':')[-1].underscore}"
end

def settings
    return @settings
end

def switch name
    
    settings.set :name, name 
    settings.set :app, settings.apps[name]
    MongoMapper.setup({'production' => {'uri' => "mongodb://localhost/#{settings.mongo_prefix}-#{settings.name}"}}, 'production')
    
end

def method_missing(m, *args, &block)
  
  ctrl = controller
     
   # puts "test "+ File.join(@settings.views, self.class.views, ctrl, "#{m}.erb") if self.class.views
 
   
   if FileTest.exist? File.join(@settings.views, ctrl, "#{m}.erb")
      
      path = File.join(ctrl,m.to_s)
      
   elsif self.class.views and FileTest.exist? File.join(@settings.views, self.class.views, ctrl, "#{m}.erb")
   
      path = File.join(self.class.views,ctrl,m.to_s)
      
   else
      
      ctrl = 'document'
      path = File.join("..","..", "gxt" ,"views", ctrl, m.to_s) 
   
   end
   
   puts "path = #{path}"
   
      @context.erb :"#{path}", :locals=>{:this=>self}
  
  
   # @context.erb :"#{self.class.name.gsub("Controller","").downcase}/#{m}"
end

end

def name service
    return service.split(":")[-1]
end

class GXTDocument < GXT
  
  
  class_attribute :module_name
  
  
  
  def model
    eval "#{self.class.name.gsub("Controller","")}"
  end
  
  def self.views
    # "../modules/user/views"
    nil
  end
  
  def method_missing(m, *args, &block)
     
     
     ctrl = controller
       
     # puts "test "+ File.join(@settings.views, self.class.views, ctrl, "#{m}.erb") if self.class.views
   
     
     if FileTest.exist? File.join(@settings.views, ctrl, "#{m}.erb")
        
        path = File.join(ctrl,m.to_s)
        
     elsif self.class.views and FileTest.exist? File.join(@settings.views, self.class.views, ctrl, "#{m}.erb")
     
        path = File.join(self.class.views,ctrl,m.to_s)
        
     else
        
        ctrl = 'document'
        path = File.join("..","..", "gxt" ,"views", ctrl, m.to_s) 
     
     end
     
     puts "path = #{path}"
     
        @context.erb :"#{path}", :locals=>{:this=>self}
    
  end
end




