
register_app 'bot', 'esm-bot'

# require_relative 'services/indexing'
require 'digest/sha1'

module EsmBot
  
  
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
  
  
  
  class Currency < GXTModel
    include Mongoid::Document
 
    
    key :name, String
    
    
    # {:e=>"kline", :E=>1621581120120, :s=>"ETHUSDT", 
    # :k=>{:t=>1621580400000, :T=>1621583999999, 
    # :s=>"ETHUSDT", :i=>"1h", :f=>437978697,
    # :L=>437996229, :o=>"2765.01000000", :c=>"2745.84000000", :h=>"2770.69000000", :l=>"2735.65000000", :v=>"11530.41315000",
    # :n=>17533, :x=>false, :q=>"31741759.08639940", :V=>"5707.94928000", :Q=>"15709133.60659390", :B=>"0"}}


  end
  
  
  
  class Price  < GXTModel
    include Mongoid::Document
 
    key :name, String
    key :datetime, Time
    key :currency_id, ObjectId
    
  end
  
  
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
  
  
  class CurrencyController < GXTDocument

  end
  
  class PriceController < GXTDocument

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

