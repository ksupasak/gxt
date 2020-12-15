module EsmMiotMonitor
  

class SHNetwork < GXTModel
  
  include Mongoid::Document
  
  key :name, String
  key :title, String
  key :address, String
  key :latlng, String
  key :phone, String
  key :district, String
  
end


class SHHospital < GXTModel
  
  include Mongoid::Document
  
  key :name, String
  key :title, String
  key :address, String
  key :latlng, String
  key :phone, String
  key :district, String
  
  
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



class SHOfficer < GXTModel
  
  include Mongoid::Document
  belongs_to :network, :class_name=>'EsmMiotMonitor::SHNetwork'

  key :name, String
  key :address, String
  key :phone, String
  key :latlng, String
  key :membered_at, Time
  key :license_number, String
  
  key :network_id, ObjectId
  key :user_id, ObjectId
  
end


class SHVisit < GXTModel
  
  include Mongoid::Document
  
  key :start, Time
  
  key :title, String
  
  key :note, String
  
  key :patient_id, ObjectId
  key :network_id, ObjectId
  key :officer_id, ObjectId
  
  key :status, String
  
  
end

class SHCaseReport < GXTModel
  
  include Mongoid::Document
  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'
  
  key :center_name, String
  key :date, Time
  key :center_address, String
  
  key :admit_id, ObjectId
  key :result, String
  
  
  key :bp_sys, Integer
  key :bp_dia, Integer
  key :bp_mean, Integer
  
  key :spo2, Integer
  key :pr, Integer
  
  key :temp, Integer
  
  key :rr, Integer
  
  
  
  include Mongoid::Timestamps
  
end



class SHCaseReportController < GXTDocument
  
end


class SHVisitController < GXTDocument
  
end

class SHUserNetworkController < GXTDocument
  
end

class SHOfficerController < GXTDocument
  
end


class SHUserHospitalController < GXTDocument
  
end



class SHNetworkController < GXTDocument
  
end



class SHHospitalController < GXTDocument
  
end



end