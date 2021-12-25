
module EsmMiotMonitor

class EMSCase < GXTModel
  
  include Mongoid::Document
  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'
  
  key :case_no, String
  
  key :chief_complain, String
      
  key :request_cbd_code, ObjectId
      
  key :init_cbd_code, ObjectId
  
  key :final_cbd_code, ObjectId
  
  key :contact_name, String
  
  key :contact_phone, String
  
  key :patient_id, ObjectId
  key :patient_name, String
  
  key :patient_cid, String
  key :patient_hn, String
  key :patient_phone, String
  
  
  key :address, String
  key :latlng, String
  
  key :note, String
  
  
      
  key :admit_id, ObjectId
  
  key :zone_id, ObjectId
  
  key :status, String
    
end

class EMSCode < GXTModel
  
  include Mongoid::Document
  
  key :code, String
  
  key :name, String
  
  key :cls, String
      
  key :description, String
  
  def get_class
    
    cls = 'primary'
    
    cls = self.cls if self.cls
    
    
  end
      
    
end

class EMSCaseCounter < GXTModel
  
  include Mongoid::Document
  
  key :key, String
  
  key :count, Integer
      
end


class EMSCaseController < GXTDocument
  
end

class EMSCodeController < GXTDocument
  
end

end


