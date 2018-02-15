
register_app 'gold', 'gxt-gold-saving'



require_relative 'controller'
require_relative 'modules/user/controller'
require_relative 'modules/member/controller'

add_module 'user'




class HomeController < GXT

def index params
  
  User.create :name=>"Soup", :age=>3
  
  @context.erb :home, :locals=>{:a=>User.count}
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
  
end

class AccountController < GXTDocument

end




class BranchController < GXTDocument

end



