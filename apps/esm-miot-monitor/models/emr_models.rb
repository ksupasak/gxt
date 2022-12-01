
require "base64"
module EsmMiotMonitor


class EMRDocument < GXTModel

  include Mongoid::Document

  key :name, String
  key :title, String
  key :schema, String
  key :sort_order, Integer

end


class EMRRecord < GXTModel

  include Mongoid::Document
  key :case_id, ObjectId
  key :document_id, ObjectId
  key :admit_id, ObjectId
  key :data, Hash
  key :stamp, DateTime

end

class EmsEMRController < GXTDocument

end


class EMRDocumentController < GXTDocument

end

class EMRRecordController < GXTDocument

end


end
