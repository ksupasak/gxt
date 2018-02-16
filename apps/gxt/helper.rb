require 'barby'
require 'barby/barcode/code_128'
require 'barby/barcode/ean_13'
require 'barby/barcode/code_39'
require 'barby/barcode/qr_code'
require 'barby/outputter/png_outputter'


def register_app name, prefix, extended=nil
  settings.apps[name] = prefix
  settings.extended[prefix] = extended if extended
  settings.apps_ws[prefix] = []
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
    
    "<a href='#{url}' #{class_opt} #{opt}>#{name}</a>"
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
  
 
  
  
  def redirect_to url, delay=0
    '<meta http-equiv="refresh" content="'+delay.to_s+'; url='+url+'" />'
  end
  
  def view v
      settings.app
  end
  
  def solve this, p
    
    
    path = :"#{params[:service].downcase}/#{p}"
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
    
    
    path = :"#{params[:service].downcase}/#{p}"
    # puts "test #{File.join("#{path}.erb")}"
    unless FileTest.exist? File.join(settings.views,"#{path}.erb")
      path = File.join("..","..", "gxt" ,"views", "document", p.to_s) 
    end
    path
    
    partial path, :locals=>{:this=>this}
    
  end
  
  
  
end


class GXT
  
def initialize context, settings
    @context = context
    @settings = settings
end  


def method_missing(m, *args, &block)
   @context.erb :"#{self.class.name.gsub("Controller","").downcase}/#{m}"
end

end

def add_module path, name, mname
  
  require_relative "#{path}/modules/#{name}/controller"
  
  include eval(mname)
    
end

class GXTDocument < GXT
  
  
  class_attribute :module_name
  
  def controller
    "#{self.class.name.gsub("Controller","").downcase.split(':')[-1]}"
  end
  
  
  def model
    eval "#{self.class.name.gsub("Controller","")}"
  end
  
  def self.views
    # "../modules/user/views"
    nil
  end
  
  def method_missing(m, *args, &block)
       ctrl = controller
       
     puts "test "+ File.join(@settings.views, self.class.views, ctrl, "#{m}.erb") if self.class.views
   
     
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




