
module Utilities
 
  module ClassMethods
    def views
      File.join("..","modules","user","views")
    end
  end
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
end

module UserAuth

class User
  include MongoMapper::Document
  
  key :login, String
  key :salt,  String
  key :hashed_password,  String
  key :last_login, DateTime
  key :role, ObjectId
  
  def self.login login, pass
        u = User.where(:login=>login).first
        if u 
          if User.encrypt(pass, u.salt)==u.hashed_password
            return u
          end
        else
          return nil
        end
  end
  
  def change_password pass, pass_confirm
    
     if pass == pass_confirm
       
       self.password = pass
       
     end
    
  end
  
  def password= pass
  
     self.salt = User.random_string(10) if !self.salt?
     self.hashed_password = User.encrypt(pass, self.salt)
   end
  
  def self.register_user login, pass
    
      user = User.create :login=>login
      user.password = pass

      return user
  end
  
  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass+salt)
  end
  
  def self.random_string(len)
     #generat a random password consisting of strings and digits
     chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
     newpass = ""
     1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
     return newpass
   end
  
end

class Role
  include MongoMapper::Document
  
  key :name, String

end


class UserController < GXTDocument
  
  include Utilities

  
  def test params
    return   UserController.module_name
  end
  
  def create params
    
    
    @context.erb :"#{self.class.views}/user/create",:layout=>:"user/layout", :locals=>{:this=>self}
    
  end
  def login params
    
    @context.erb :"#{self.class.views}/user/login",:layout=>:"user/layout", :locals=>{:this=>self}
  
  end
  
  
end

class RoleController < GXTDocument
  
  include Utilities
  
end

end


