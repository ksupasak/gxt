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
def normalize_distance_of_time_argument_to_time(value)
        if value.is_a?(Numeric)
          Time.at(value)
        elsif value.respond_to?(:to_time)
          value.to_time
        else
          raise ArgumentError, "#{value.inspect} can't be converted to a Time value"
        end
      end
def time_ago_in_words(from_time, options = {})
  
  distance_of_time_in_words(from_time, Time.now, options) if from_time
end

def distance_of_time_in_words(from_time, to_time = 0, options = {})
  options = {
    scope: :'datetime.distance_in_words'
  }.merge!(options)

  from_time = normalize_distance_of_time_argument_to_time(from_time)
  to_time = normalize_distance_of_time_argument_to_time(to_time)
  from_time, to_time = to_time, from_time if from_time > to_time
  distance_in_minutes = ((to_time - from_time) / 60.0).round
  distance_in_seconds = (to_time - from_time).round

  I18n.with_options locale: options[:locale], scope: options[:scope] do |locale|
    case distance_in_minutes
    when 0..1
      return distance_in_minutes == 0 ?
             locale.t(:less_than_x_minutes, count: 1) :
             locale.t(:x_minutes, count: distance_in_minutes) unless options[:include_seconds]

      case distance_in_seconds
      when 0..4   then locale.t :less_than_x_seconds, count: 5
      when 5..9   then locale.t :less_than_x_seconds, count: 10
      when 10..19 then locale.t :less_than_x_seconds, count: 20
      when 20..39 then locale.t :half_a_minute
      when 40..59 then locale.t :less_than_x_minutes, count: 1
        else             locale.t :x_minutes,           count: 1
      end

    when 2...45           then locale.t :x_minutes,      count: distance_in_minutes
    when 45...90          then locale.t :about_x_hours,  count: 1
      # 90 mins up to 24 hours
    when 90...1440        then locale.t :about_x_hours,  count: (distance_in_minutes.to_f / 60.0).round
      # 24 hours up to 42 hours
    when 1440...2520      then locale.t :x_days,         count: 1
      # 42 hours up to 30 days
    when 2520...43200     then locale.t :x_days,         count: (distance_in_minutes.to_f / 1440.0).round
      # 30 days up to 60 days
    when 43200...86400    then locale.t :about_x_months, count: (distance_in_minutes.to_f / 43200.0).round
      # 60 days up to 365 days
    when 86400...525600   then locale.t :x_months,       count: (distance_in_minutes.to_f / 43200.0).round
      else
      from_year = from_time.year
      from_year += 1 if from_time.month >= 3
      to_year = to_time.year
      to_year -= 1 if to_time.month < 3
      leap_years = (from_year > to_year) ? 0 : (from_year..to_year).count { |x| Date.leap?(x) }
      minute_offset_for_leap_year = leap_years * 1440
      # Discount the leap year days when calculating year distance.
      # e.g. if there are 20 leap year days between 2 dates having the same day
      # and month then the based on 365 days calculation
      # the distance in years will come out to over 80 years when in written
      # English it would read better as about 80 years.
      minutes_with_offset = distance_in_minutes - minute_offset_for_leap_year
      remainder                   = (minutes_with_offset % MINUTES_IN_YEAR)
      distance_in_years           = (minutes_with_offset.div MINUTES_IN_YEAR)
      if remainder < MINUTES_IN_QUARTER_YEAR
        locale.t(:about_x_years,  count: distance_in_years)
      elsif remainder < MINUTES_IN_THREE_QUARTERS_YEAR
        locale.t(:over_x_years,   count: distance_in_years)
      else
        locale.t(:almost_x_years, count: distance_in_years + 1)
      end
    end
  end
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

  

def default_layout 
 true
end

  
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
    # MongoMapper.setup({'production' => {'uri' => "mongodb://#{MONGO_HOST}/#{settings.mongo_prefix}-#{settings.name}"}}, 'production')
    Mongoid.override_database("#{settings.mongo_prefix}-#{settings.name}")
    
end

def method_missing(m, *args, &block)
  
  ctrl = controller
     
   # puts "test "+ File.join(@settings.views, self.class.views, ctrl, "#{m}.erb") if self.class.views
  
  # , :layout => false
   
   layout = default_layout
   
   # puts "LOOK #{File.join(@settings.views, self.class.views, ctrl, "_#{m}.erb")}"
   
   if FileTest.exist? File.join(@settings.views, ctrl, "#{m}.erb")
      
      path = File.join(ctrl,m.to_s)
      
   elsif self.class.views and FileTest.exist? File.join(@settings.views, self.class.views, ctrl, "#{m}.erb")
   
      path = File.join(self.class.views,ctrl,m.to_s)
      
   elsif FileTest.exist? File.join(@settings.views, ctrl, "_#{m}.erb")
      path = File.join(ctrl,"_"+m.to_s)
      layout = false
      
   elsif self.class.views and FileTest.exist? File.join(@settings.views, self.class.views, ctrl, "_#{m}.erb")
     path = File.join(self.class.views,ctrl,"_"+m.to_s)
       layout = false
   else
      
      ctrl = 'document'
      path = File.join("..","..", "gxt" ,"views", ctrl, m.to_s) 
   
   end
   
   puts "path = #{path}"
   
      @context.erb :"#{path}", :locals=>{:this=>self}, :layout=>layout
  
  
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
   
    layout = default_layout

     
     if FileTest.exist? File.join(@settings.views, ctrl, "#{m}.erb")
        
        path = File.join(ctrl,m.to_s)
      
     elsif self.class.views and FileTest.exist? File.join(@settings.views, self.class.views, ctrl, "#{m}.erb")
     
        path = File.join(self.class.views,ctrl,m.to_s)
        
     elsif FileTest.exist? File.join(@settings.views, ctrl, "_#{m}.erb")

              path = File.join(ctrl,'_'+m.to_s)
              layout = false

        elsif self.class.views and FileTest.exist? File.join(@settings.views, self.class.views, ctrl, "_#{m}.erb")

              path = File.join(self.class.views,ctrl,'_'+m.to_s)
              layout = false
              
     else
        
        ctrl = 'document'
        path = File.join("..","..", "gxt" ,"views", ctrl, m.to_s) 
     
     end
     
     puts "path = #{path}"
     
        @context.erb :"#{path}", :locals=>{:this=>self}, :layout=>layout
    
  end
end




