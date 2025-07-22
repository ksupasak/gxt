
register_app 'console', 'gxt-console'

module GxtConsole
  
    class HomeController < GXT
      
          #
       def index params
         # return 'sidojfsdffff'
         @context.erb :'home/index', :locals=>{:now=>Time.now}
         
       end
      
   
      
    end
  
end

  module Sinatra


   register GxtConsole

  end