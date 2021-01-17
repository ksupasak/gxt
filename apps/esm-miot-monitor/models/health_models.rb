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
  
  belongs_to :hospital, :class_name=>'EsmMiotMonitor::SHHospital', :foreign_key=>:hospital_id
  belongs_to :provider, :class_name=>'EsmMiotMonitor::Provider'
  belongs_to :user, :class_name=>'EsmMiotMonitor::User'
  
  
  key :user_id, ObjectId
  key :hospital_id, ObjectId
  key :provider_id, ObjectId
  key :provider_type, String
  
end


class SHUserNetwork < GXTModel
  
  include Mongoid::Document
  
  belongs_to :network, :class_name=>'EsmMiotMonitor::SHNetwork',  :foreign_key=>:network_id
  belongs_to :provider, :class_name=>'EsmMiotMonitor::Provider'
  belongs_to :user, :class_name=>'EsmMiotMonitor::User'
  
  key :user_id, ObjectId
  key :network_id, ObjectId
  key :provider_id, ObjectId
   key :provider_type, String
  
end

class SHRelation < GXTModel
  
  include Mongoid::Document
  
  belongs_to :patient, :class_name=>'EsmMiotMonitor::Patient'
  
  
  key :hospital_doctor_id, ObjectId
  key :hospital_nurse_id, ObjectId
  key :network_doctor_id, ObjectId
  key :network_nurse_id, ObjectId
  key :network_officer_id, ObjectId
  key :patient_id, ObjectId
  
  
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
  
  key :privilege, String
  key :appoint, String
  key :diag, String
  key :n18, String
  key :e11, String
  key :diag_etc, String
  
  key :bp_target, String
  key :bp_control, String
  key :bp_fix, String
  key :glucose_target, String
  key :glucose_control, String
  key :glucose_fix, String
  key :fat_target, String
  key :fat_control, String
  key :fat_fix, String

  key :egfr, String
  key :egfr_fix, String

  key :heent, String
  key :heart, String
  key :ext, String
  key :neuro, String
  key :body_etc, String

  key :med, String
  
  include Mongoid::Timestamps
  
end



class SHCaseReportController < GXTDocument
  
end

class SHRelationController < GXTDocument
  
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