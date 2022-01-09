
module EsmMiotMonitor

class EMSCase < GXTModel
  
  include Mongoid::Document
  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'
  
  has_many :commands, :class_name=>'EsmMiotMonitor::EMSCommand', order: "created_at ASC", foreign_key: 'case_id'
  
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

class EMSKWorkflow < GXTModel
  
  include Mongoid::Document
  
  key :name, String
  
  key :code, String
      
end

class EMSKProcess < GXTModel
  
  include Mongoid::Document
  
  key :name, String
  
  key :order, Float

  key :kworkflow_id, ObjectId
      
end

class EMSKAction < GXTModel
  
  include Mongoid::Document
  
  key :name, String

  key :linkto, Float

  key :kprocess_id, ObjectId
        
end

class EMSCaseWorkflow < GXTModel
  
  include Mongoid::Document
  
  key :case_id, ObjectId
  key :kworkflow_id, ObjectId
      
end

class EMSCaseProcess < GXTModel
  
  include Mongoid::Document
  
  key :case_id, ObjectId
  key :case_workflow_id, ObjectId
  key :kprocess_id, ObjectId
      
end

class EMSCaseAction < GXTModel
  
  include Mongoid::Document
  
  key :case_id, ObjectId
  key :case_process_id, ObjectId
  key :kaction_id, ObjectId
  key :name, String

        
end


class EMSCommand < GXTModel
  
  include Mongoid::Document
  
  belongs_to :ambulance, :class_name=>'EsmMiotMonitor::Ambulance',  foreign_key: 'ambulance_id'
  has_many :providers, :class_name=>'EsmMiotMonitor::EMSCommandProvider', foreign_key: 'command_id'
  
  
  key :case_id, ObjectId
  key :init_command, String
  key :ambulance_id, ObjectId
  key :note, String

        
end



class EMSCommandProvider < GXTModel
  
  include Mongoid::Document
  belongs_to :provider, :class_name=>'EsmMiotMonitor::Provider'
  key :command_id, ObjectId
  key :provider_id, ObjectId
  key :position, String
  key :name, String
  key :note, String
  key :sort_order, Integer
        
end


class LineAccount < GXTModel
  
  include Mongoid::Document
  
  has_many :messages, :class_name=>'EsmMiotMonitor::LineMessage', foreign_key: 'account_id'
  
  key :name, String
  
  key :user_id, String
  
  key :type, String

        
end

class LineMessage < GXTModel
  
  include Mongoid::Document
  
  belongs_to :account, :class_name=>'EsmMiotMonitor::LineAccount',  foreign_key: 'account_id'
  
  key :account_id, ObjectId
  
  key :message_id, String
  key :user_id, String
  
  key :type, String
  key :message_type, String
  key :text, String
  key :source_type, String
  
  key :content, String
  
    include Mongoid::Timestamps

        
end

class LineAccountController < GXTDocument
  
end

class LineMessageController < GXTDocument
  
end

class EMSCaseController < GXTDocument
  
end

class EMSCodeController < GXTDocument
  
end


class EMSCaseWorkflowController < GXTDocument
  
end

class EMSCaseProcessController < GXTDocument
  
end

class EMSCaseActionController < GXTDocument
  
end

class EMSKWorkflowController < GXTDocument
  
end

class EMSKProcessController < GXTDocument
  
end

class EMSKActionController < GXTDocument
  
end

class EMSCommandController < GXTDocument
end

class EMSCommandProviderController < GXTDocument
end


end