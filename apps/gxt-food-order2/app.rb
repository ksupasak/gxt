
register_app 'food3', 'gxt-food-order3'



module Sinatra
  module FoodOrder
    def self.registered(app)

      app.set :gem_images, File.expand_path( "apps/gxt-food-order/public", File.dirname(__FILE__))

      app.get "/images/:file" do |file|
        send_file File.join( settings.gem_images, file)
      end

      app.get "/gemapp" do
        "running"
      end
    end
  end
  register FoodOrder
end

class User
  include MongoMapper::Document
  key :name, String
  key :age,  Integer
end


class Home < GXT

def index params
  
  User.create :name=>"Soup", :age=>3
  
  @context.erb :home, :locals=>{:a=>User.count}
end

end


class Home2 < Home


def test params
  
  params[:msg] = "soup from home2"
  
  @context.erb :home

end

end






