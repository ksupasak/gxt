
register_app 'endopacs', 'esm-media-stream'
require_relative 'services/indexing'

module EsmMediaStream
  
  include EsmMediaStreamIndex
  
  class Setting  < GXTModel
    include Mongoid::Document
 
      key :name, String
      key :value, String
      
   
      
        def self.get name, default=nil
            record = self.where(:name=>name).first
            unless record
              record = self.create :name=>name, :value=>default
            end
            return record.value
        end
      
      def self.get_value key
        get key
      end
      
  end
  
  class Session  < GXTModel
    include Mongoid::Document
 
    key :datetime, Time
    key :solution, String
    key :name, String
    key :key, String
    key :ref, String
    key :op, String
    key :favorite, Integer
    key :note, String
    
  end
  
  # class Setting  < GXTModel
  #   include Mongoid::Document
  #   key :name, String
  #   key :value, String
  #   include Mongoid::Timestamps
  #
  #   def self.get name, default=nil
  #       record = self.where(:name=>name).first
  #       unless record
  #         record = self.create :name=>name, :value=>default
  #       end
  #       return record.value
  #   end
  # end

  
  class Video < GXTModel
    include Mongoid::Document
 
    
    key :datetime, Time
    key :name, String
    key :session_id, ObjectId
    key :path, String
    key :raw_size, Integer
  end
  
  
  
  class ScanPath  < GXTModel
    include Mongoid::Document
 
    key :name, String
    key :content_path, String
    key :path, String
    
    
  end
  
  require 'digest/sha1'
  class User < GXTModel

    include Mongoid::Document
 
    belongs_to :role, :class_name=>'EsmMiotMonitor::Role'
    key :login, String
    key :salt,  String
    key :passcode, String
    key :pattern, String
    key :hashed_password,  String
    key :last_accessed, DateTime
    key :role_id, ObjectId
    key :email, String
     include Mongoid::Timestamps
    timestamps!
  
    def self.authenticate(login, pass)
      u=  self.where(:login=>login).first()
      return nil if u.nil?
      if User.encrypt(pass, u.salt)==u.hashed_password
        u.last_accessed = Time.now
        u.save
        return u
      end
      nil
    end
  
    def password=(pass)
      @password=pass
      self.salt = User.random_string(10) if !self.salt?
      self.hashed_password = User.encrypt(@password, self.salt)
    end
  
    def login_perform
      self.last_accessed = Time.now
      self.save
      self
    end
  
    def self.random_string(len)
      #generat a random password consisting of strings and digits
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      newpass = ""
      1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
      return newpass
    end
  
    def self.encrypt(pass, salt)
      Digest::SHA1.hexdigest(pass+salt)
    end
  
  end

  class Role < GXTModel
    include Mongoid::Document

    key :name, String
    include Mongoid::Timestamps 
    timestamps!
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
  
  
  class UserController < GXTDocument
    def acl
      return {'*'=>'*'}
    end
  end
  
  class RoleController < GXTDocument

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
