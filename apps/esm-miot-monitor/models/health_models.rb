module EsmMiotMonitor


class SHAddressBook < GXTModel
  
  
  def self.getList user
      
      
      # determine user role
      
      role = Role.find user.role
      
      
      case role
        
      when 'hospitat' 
        
      end
      
      user_hospital = SHUserHospital.where(:user_id=>user.id).first
      user_network  = SHUserNetwork.where(:user_id=>user.id).first
      
      providers = Provider.all
      
      pmap = {}
      
      for i in providers
          
        pmap[i.id] = i
      end
      
      list = []
      
      
      
      if user_hospital
        
        hospital = SHHospital.find user_hospital.hospital_id
        
        networks = SHNetwork.where(:hospital_id=>hospital.id).all
        
        # find all network operator of sub network
        hlist = []
        
        for u in SHUserHospital.where(:hospital_id=>hospital.id).all
          
          if u.id != user_hospital.id and ( u.provider_type=='operator' || u.provider_type == 'doctor' )
            
            us = User.find(u.user_id)  
            role = Role.find us.role_id
            udata = {:id=>u.user_id, :user=>us, :provider_type=>u.provider_type,:role=>role.name, :provider=>pmap[u.provider_id]}
            
             hlist << udata  
            
          end
          
        end
        
         list << {:name=>hospital.name, :code=>hospital.code, :list=>hlist, :type=>'hospital'}
        
        
        for n in networks
            
          nlist = []
          
          for u in SHUserNetwork.where(:network_id=>n.id).all
            
            if u.provider_type == 'operator' || u.provider_type == 'officer'  
              us = User.find(u.user_id)  
              if us 
              role = Role.find us.role_id
              udata = {:id=>u.user_id, :user=>us, :provider_type=>u.provider_type,:role=>role.name, :provider=>pmap[u.provider_id]}
            
              nlist << udata  
              else
                u.destroy
              end
            
            end
            
          end
            
          list << {:name=>n.name, :code=>n.code, :list=>nlist, :type=>'network'}
          
          
        end  
        
      elsif user_network
        
        
        network = SHNetwork.find user_network.network_id
        
        
        hospital = SHHospital.find network.hospital_id
        
       
        
        # find all network operator of sub network
        hlist = []
        
        if hospital
        
        for u in SHUserHospital.where(:hospital_id=>hospital.id).all
          
        
            if u.provider_type == 'operator' || u.provider_type == 'doctor' 
            
            us = User.find(u.user_id)  
            role = Role.find us.role_id
            udata = {:id=>u.user_id, :user=>us, :provider_type=>u.provider_type,:role=>role.name,:provider=>pmap[u.provider_id]}
            
             hlist << udata  
            
             end
          
        end
        
        
         list << {:name=>hospital.name, :code=>hospital.code, :list=>hlist, :type=>'hospital'}
        
       end
        
           n = network
            
          nlist = []
          
          for u in SHUserNetwork.where(:network_id=>n.id).all
              
              
          if u.id != user_network.id 
              
            us = User.find(u.user_id)  
            role = Role.find us.role_id
            udata = {:id=>u.user_id, :user=>us, :provider_type=>u.provider_type,:role=>role.name,:provider=>pmap[u.provider_id]}
            
            nlist << udata  
          end
            
          end
            
          list << {:name=>n.name, :code=>n.code, :list=>nlist, :type=>'network'}
          
          
       
        
      end
      
      
      
      
      
      
      
      
      
      return list 
      
      
      
      
  end
  
end  

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
  belongs_to :hospital, :class_name=>'EsmMiotMonitor::SHHospital', :foreign_key=>:hospital_id
  
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
  key :appointed_date, Time
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


  key :data_record_id, ObjectId # user
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