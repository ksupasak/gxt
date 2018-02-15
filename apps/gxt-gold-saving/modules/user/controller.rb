
class User
  include MongoMapper::Document
  
  key :login, String
  key :salt,  String
  key :hash_password,  String
  key :last_login, DateTime
  
end

class Role
  include MongoMapper::Document
  
  key :name, String

end


class UserController < GXTDocument
  def test params
    return 'test'
  end
end

class RoleController < GXTDocument

end