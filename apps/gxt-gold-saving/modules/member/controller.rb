class Member
  include MongoMapper::Document
  key :name, String
  key :code, String
  key :first_name, String
  key :last_name, String
  key :tel, String
  key :address, String


end

class MemberController < GXTDocument

end