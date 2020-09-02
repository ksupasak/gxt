module EsmMiotMonitor
  

class ERCaseReport < GXTModel
  
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
  
  
  
  key :chief_complaint, String
  
  key :level, String
  
  
  key :trauma_status, String
  
  
  key :trauma_concious, String
  
  key :trauma_wound, String
  
  key :trauma_bone, String
  
  key :trauma_blood, String
  
  key :trauma_organ, String
  
  
  key :non_trauma_med, String
  
  key :non_trauma_wound, String
  
  
  
  include Mongoid::Timestamps
  
end



class ERCaseReportController < GXTDocument
  
end



end