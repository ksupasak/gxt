
register_app 'gold', 'gxt-gold-saving'


module GxtGoldSaving


# require_relative 'modules/user/controller'
# require_relative 'modules/cms/controller'

add_module __dir__, 'user', 'GXTUserAuth'
add_module __dir__, 'cms', 'GXTCMS'

include GXTUserAuth
include GXTCMS

class HomeController < GXT

def index params
  
  # User.create :name=>"Soup", :age=>3
  
  @context.erb :home, :locals=>{:a=>GXTUserAuth::User.count}
end

def test params
  return 'sidojfsdf'
end

end




class Branch
  include MongoMapper::Document
  
  key :name, String
  key :tel, String
  key :address, String
  
  key :bank_acc, String
    timestamps!
end


class Account
  include MongoMapper::Document
  
  key :gold_price, Float
  key :weight, Float
  key :total_amount, Float
  
  key :code, Integer
  
  key :open_date, Date
  key :open_time, Time
  
  key :status, String
  key :sale, String
  key :sale_id, ObjectId
  key :member_id, ObjectId
    timestamps!
end

class Member
  include MongoMapper::Document
  key :name, String
  key :code, String
  key :first_name, String
  key :last_name, String
  key :tel, String
  key :address, String
  timestamps!
 

end

class MemberController < GXTDocument

end

class AccountController < GXTDocument

end




class BranchController < GXTDocument

end

end

