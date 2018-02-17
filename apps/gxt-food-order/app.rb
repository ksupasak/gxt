
register_app 'food', 'gxt-food-order'
register_app 'gold', 'gxt-food-order'



module GxtFoodOrder

class User
  include MongoMapper::Document
  # key :name, String
  # key :age,  Integer
end

class Order
  include MongoMapper::Document
  key :date, DateTime
  key :order_number, String
  key :sub_total, Float
  key :amount_total, Float
  key :vat_total, Float
  key :service_charge, Float
  key :status, String
  key :table_number, String
  key :queue_number, String
  key :pax, Integer
  key :station, String
  

  
  def self.next_order
    last = self.last
    t = Time.now 
    n = 0
    puts 'last'+last.inspect 
    if last
      n = last.order_number[6..-1].to_i
    end
    
     return "#{t.strftime("%y%m%d")}#{format("%06d",n+1)}"
    
  end
  
  def self.next_queue
    t = Time.now 
    mid = Date.parse(t.strftime("%Y-%m-%d")).to_datetime
    tom = mid+1
    c = Order.where(:date=>{'$lte'=> Date.to_mongo(tom),'$gte'=> Date.to_mongo(mid)}).count
    
    return "#{format('%04d',c+1)}"
    
  end
  
end

class OrderItem
  include MongoMapper::Document
  key :order_id, ObjectId
  key :product_id, ObjectId
  key :quantity, Integer
  key :note, String
  key :amount, Float
  
end



class ProductCategory
  include MongoMapper::Document
  key :name, String
  key :description, String
  key :date, DateTime
end

class Setting
  include MongoMapper::Document
  
  key :name, String
  key :value, String
end

class Device
  include MongoMapper::Document
  
  key :name, String
  key :params, String
  key :title, String
  key :type, String
end

class Product
  include MongoMapper::Document
  key :name, String
  key :description, String
  key :price,  Float
  key :product_category_id, ObjectId
  key :image_1, ObjectId
  key :image_2, ObjectId
  key :image_3, ObjectId
end
class Adv
  include MongoMapper::Document
  key :name, String
  key :description, String
  key :url, String
  key :image_1, ObjectId
end
class Attachment
  include MongoMapper::Document
  key :title,String
  key :selected,Integer
  key :params,String
  key :ref,String
  key :filename,String
  key :path,String
  key :project_id,Integer
  key :ssid,String
  key :file_id,ObjectId
  key :thumb_id,ObjectId
end

# Object.send(:remove_const, :Home) if   Object.const_defined?('Home')
class HomeController < GXT

def index params
  
  # User.create :name=>"Soup", :age=>3
  
  @context.erb :home, :locals=>{:a=>User.count}
end

end

# Object.send(:remove_const, :Home2) if   Object.const_defined?('Home2')
class Home2Controller < HomeController


def test params
  
  params[:msg] = "soup from home2"
  
  @context.erb :home

end

end

class AttachmentController <GXT
  def content params
    att = Attachment.find params[:id]
    if att
     
      grid = Mongo::Grid.new(MongoMapper.database)

        file = nil
        content = nil
        @context.content_type 'image/png'

        if params[:thumb] 

          if att.thumb_id == nil or (file = grid.get(att.thumb_id) )== nil or params[:thumb]=='2'
               ofile = grid.get(att.file_id)
               ext = ofile.filename.split(".")[-1]
               ext = 'jpg'
               filename= ofile.filename
               fname = "tmp/cache/#{att.file_id}.#{ext}"
               rname = "tmp/cache/#{att.file_id}_thumb.#{ext}"
               f = File.open(fname,'w')
               f.write ofile.read.force_encoding('utf-8') 
               f.close
               size = '128x128'
               size = '256x256' if params[:thumb]=='2'
               puts `/usr/local/bin/convert -resize #{size} #{fname} #{rname}`
               file = File.open(rname,'r')
               content = file.read
               file.close
               File.delete fname
               File.delete rname
               id = grid.put(content,:filename=>filename)
               # puts "new id #{id}"
               att.update_attributes :thumb_id=>id
               file = grid.get(att.thumb_id)

         else
            content = file.read     
         end



        else
                file = grid.get(att.file_id)
                content = file.read
        end

     
     
        return content
     
    end
   
  end
end

class UserController < GXTDocument

end

# Object.send(:remove_const, :Home2) if   Object.const_defined?('Home2')
class ProductController < GXTDocument

end

class AdvController < GXTDocument

end

class OrderController < GXTDocument

end

class OrderItemController < GXTDocument

end

class DeviceController < GXTDocument

end


class ProductCategoryController < GXTDocument

end
class SettingController < GXTDocument

end

# Object.send(:remove_const, :Home2) if   Object.const_defined?('Home2')
class TerminalController < GXT
  def index params
    @context.erb :"terminal/index", :layout=>:"terminal/wizard_layout"
  end
  def show params
    @context.erb :"terminal/show", :layout=>:"terminal/wizard_layout"
  end
  def wizard params
    @context.erb :"terminal/wizard", :layout=>:"terminal/wizard_layout"
  end
end
# Object.send(:remove_const, :Home2) if   Object.const_defined?('Home2')
class VendingController < GXT
  def index params
    @context.erb :"vending/index", :layout=>:"terminal/wizard_layout"
  end

end
# Object.send(:remove_const, :Home2) if   Object.const_defined?('Home2')
class  KitchenController < GXT
  def index params
    @context.erb :"kitchen/index", :layout=>:"kitchen/layout"
  end
end



end


