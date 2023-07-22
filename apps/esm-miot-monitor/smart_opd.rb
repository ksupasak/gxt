
module EsmMiotMonitor
  
class SmartOPDController < GXTDocument
 
  def acl
    
    # return {:index=>'*',:entry=>'*',:log=>'*',:result=>'*',:post=>'*',:find_patient=>'*',:_find_patient=>'*'}
    
    return {'*'=>true}
    
  end
 
  def default_layout
    return :opd_layout
  end
 
end

end