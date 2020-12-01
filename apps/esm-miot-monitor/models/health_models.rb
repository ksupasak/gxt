module EsmMiotMonitor
  

class SHNetwork < GXTModel
  
  include Mongoid::Document
  
  key :name, String
  key :title, String
  key :address, String
  key :latlng, String
  
  
end


class SHHospital < GXTModel
  
  include Mongoid::Document
  
  key :name, String
  key :title, String
  key :address, String
  key :latlng, String
  
  
end



class SHUserHospital < GXTModel
  
  include Mongoid::Document
  
  key :user_id, ObjectId
  key :hospital_id, ObjectId
  
end


class SHUserNetwork < GXTModel
  
  include Mongoid::Document
  
  key :user_id, ObjectId
  key :network_id, ObjectId
  
  
end



class SHUserNetworkController < GXTDocument
  
end


class SHUserHospitalController < GXTDocument
  
end



class SHNetworkController < GXTDocument
  
end



class SHHospitalController < GXTDocument
  
end



end