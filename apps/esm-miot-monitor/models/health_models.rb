module EsmMiotMonitor
  

class SHConference < GXTModel
  
    include Mongoid::Document
  
    key :status, String  # New (Waiting), Accepted, Finished, Cancelled
    key :admit_id, ObjectId
    key :resource_id, String
    
    key :sender_user_id, ObjectId
    key :sender_role, String
    key :receiver_user_id, ObjectId
    key :receiver_role, String
    
    key :group_id, ObjectId
    
    key :title, String
    key :schedule, Time
    
    key :note, String
  
    include Mongoid::Timestamps
end

class SHAlert < GXTModel
  
    include Mongoid::Document
  
    key :status, String  # New (Pending), OnHold, Closed
    key :admit_id, ObjectId
    key :patient_id, ObjectId
    
    key :sense, String
    key :value, Float
    key :condition, String
    
    key :patient_user_id, ObjectId
    key :patient_ack, String
    key :patient_ack_at, Time
    
    key :operator_user_id, ObjectId
    key :operator_ack, String
    key :operator_ack_at, Time

    key :closed_at, Time
    
    key :note, String
  
    include Mongoid::Timestamps
    
    def self.vs_condition sense, val
      
      
			if sense==:temp and temp = val.to_f and temp != 0 
				
				if temp <= 36.5
					 return [:temp, :low, temp]
				elsif temp >=38
					 return [:temp, :high, temp]
				end
				
      elsif sense==:pr and pr = val.to_i and pr != 0 
				
				if pr <= 60
				  return [:pr, :low, pr]
				elsif pr >=100
					return [:pr, :high, pr]
				end
				
      elsif sense == :rr and val = val.to_i and val != 0 
				
				if val <= 14
					return [:rr, :low, val]
				elsif val >= 22
					return [:rr, :high, val]
				end
				
      elsif sense == :spo2 and val = val.to_i  and val != 0 
				
				if val <= 95
					return [:spo2, :low, val]
				end
				
			end
      
      return nil
      
    end
    
    
end


class SHNetwork < GXTModel
  
  include Mongoid::Document
  
  key :name, String
  key :title, String
  key :address, String
  key :latlng, String
  key :phone, String
  key :district, String
  key :code, String
  
  key :hospital_id, ObjectId
  
end


class SHHospital < GXTModel
  
  include Mongoid::Document
  
  key :name, String
  key :title, String
  key :address, String
  key :latlng, String
  key :phone, String
  key :district, String
  key :code, String
  
  
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
  
  key :hospital_id, ObjectId
  key :hospital_doctor_id, ObjectId
  key :hospital_doctor_2_id, ObjectId
  key :hospital_nurse_id, ObjectId
  key :network_id, ObjectId
  key :network_doctor_id, ObjectId
  key :network_nurse_id, ObjectId
  key :network_officer_id, ObjectId
  key :patient_id, ObjectId
  key :user_id, ObjectId
  
  
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
  
  
  key :appoint_type, String # at hospital , at network order
  key :date, Time
  key :status, String
  key :start, Time
  
  
  key :patient_id, ObjectId

  
  
  key :title, String
  key :note, String
  
  key :provider_id, ObjectId
  key :hospital_id, ObjectId
  key :network_id, ObjectId
  key :officer_id, ObjectId
  
  
  key :app_no, String
  
  key :appointed_at, Time
  key :appointed_user, ObjectId # user
  
  key :dispatched_at, Time
  key :dispatched_user, ObjectId # user
  
  key :completed_at, Time
  key :completed_user, ObjectId # user
  key :complated_by, String # 1 : hospital , 2 : network , 3 : officer

  #
  # def self.start
  #   return self.date
  # end

  
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
  
  key :updated_user_id, ObjectId
  
  include Mongoid::Timestamps
  
end

class SHConferenceController < GXTDocument
  
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

class SHAlertController < GXTDocument
  
end


class SHHospitalController < GXTDocument
  
end



end