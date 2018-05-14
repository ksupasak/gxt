
register_app 'endopacs', 'esm-media-stream'
require_relative 'services/indexing'

module EsmMediaStream
  
  include EsmMediaStreamIndex
  
  class Setting
    include MongoMapper::Document
      key :name, String
      key :value, String
      
      
      def self.get_value key
         v = self.where(:name=>key).first
         if v 
           v.value
          else
            nil
          end
      end
      
  end
  
  class Session
    include MongoMapper::Document
    key :datetime, Time
    key :solution, String
    key :name, String
    key :key, String
    key :ref, String
    key :op, String
    key :favorite, Integer
    key :note, String
    
  end

  
  class Video
    include MongoMapper::Document
    
    key :datetime, Time
    key :name, String
    key :session_id, ObjectId
    key :path, String
    key :raw_size, Integer
  end
  
  
  
  class ScanPath
    include MongoMapper::Document
    key :name, String
    key :content_path, String
    key :path, String
    
    
  end
  
  # a = {:solution=>t[2],:key=>key,:op=>op,:id=>id,:name=>name,:track=>track_name, :path=>i, :raw_size=> File.size(i)}
  class SettingController < GXTDocument

  end
  
  
  class SessionController < GXTDocument

  end
  
  class ScanPathController < GXTDocument

  end
  
  class VideoController < GXTDocument

  end
  
  class HomeController < GXT
      
      
      
      
  end
  
end


# module Sinatra
#  
# include EsmMediaStream
#     # 
#     # module MyApplication
#     # 
#     # def self.registered(app)
#     #   
#     #   
#     # 
#     # 
#     # end
#     # 
#     # end
#     
#     # register MyApplication
# end
# 
