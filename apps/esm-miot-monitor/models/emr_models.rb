
require "base64"
module EsmMiotMonitor


class EMRDocument < GXTModel

  include Mongoid::Document

  key :name, String
  key :title, String
  key :schema, String
  key :sort_order, Integer
  
  key :type, String # docuseal_link
  key :template_id, String # docuseal_link
  key :link, String 
  

end


class EMRRecord < GXTModel

  include Mongoid::Document
  key :case_id, ObjectId
  key :document_id, ObjectId
  key :admit_id, ObjectId
  key :data, Hash
  key :stamp, DateTime
  key :submission_id, String

end

class EmsEMRController < GXTDocument

  def acl

    return {:webhook=>'*'}

  end

end


class EMRDocumentController < EMSGXTDocument

end

class EMRRecordController < EMSGXTDocument

end


end
