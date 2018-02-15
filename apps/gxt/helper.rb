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

def add_module name
  
  
  
end


helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
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

class GXTDocument < GXT
  def controller
    "#{self.class.name.gsub("Controller","").downcase}"
  end
  def model
    eval "#{self.class.name.gsub("Controller","")}"
  end
  
  
  def method_missing(m, *args, &block)
     
     
     puts File.join(@settings.views,controller,"#{m}.erb").inspect 
     unless FileTest.exist? File.join(@settings.views,controller,"#{m}.erb")
        
        #old path
        # tmp = @settings.views
        # @settings.set :views, File.join(@settings.root.to_s) 
        controller = 'document'
        path = File.join("..","..", "gxt" ,"views", controller.to_s, m.to_s) 
        content = @context.erb :"#{path}",{:locals=>{:this=>self},:layout=>:"/layout"}
        # @settings.set :views, tmp
        
        
        content
        
     else
       puts "Controller : #{self.controller}"
        @context.erb :"#{self.controller}/#{m}", :locals=>{:this=>self}
     end
  end
end




