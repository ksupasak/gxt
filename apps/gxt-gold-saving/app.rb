
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


class UserBranch
  include MongoMapper::Document
  
  key :user_id, ObjectId
  key :branch_id, ObjectId
  
end

class GoldPrice
  
  include MongoMapper::Document

 
   key :buying_price, Float
   key :salling_price, Float
   key :buying_price_2, Float
   key :salling_price_2, Float
   timestamps!
   
end


class Branch
  include MongoMapper::Document
  
  key :name, String
  key :tel, String
  key :address, String
  
  key :bank_acc, String
  
  key :prompt_pay_acc, String
  
    timestamps!
end


class Account
  include MongoMapper::Document
  
  key :code, String
  key :gold_price, Float
  key :weight, Float
  key :total_amount, Float
  key :balance, Float
  
  
  key :open_date, Date
  key :open_time, Time
  
  key :status, String
  key :sale, String
  key :sale_id, ObjectId
  key :member_id, ObjectId
  key :branch_id, ObjectId
  
    timestamps!
end

class Transaction
  include MongoMapper::Document
  
  key :code, String
  key :amount, Float
  key :payment_type, String
  key :status, String
  key :sale, String
  key :sale_id, ObjectId
  key :account_id, ObjectId
  
    timestamps!
end

class Member
  include MongoMapper::Document
  key :code, String
  key :name, String
  key :first_name, String
  key :last_name, String
  key :personal_id, String
  
  key :tel, String
  key :address, String
  key :branch_id, ObjectId
  
  timestamps!
 

end


class MemberController < GXTDocument

end

class GoldPriceController < GXTDocument

end

class AccountController < GXTDocument
  
  def print params
    @context.erb :"#{self.class.views}/account/print",:layout=>:"print", :locals=>{:this=>self}
    
  end
end

class TransactionController < GXTDocument

end


class BranchController < GXTDocument

end

end

