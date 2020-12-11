
module EsmMiotMonitor
  
class SmartOPDController < GXT
 
  def acl
    
    return {:index=>'*',:entry=>'*',:log=>'*',:result=>'*',:post=>'*'}

    
  end
 
  def default_layout
    return :opd_layout
  end
 
end

end