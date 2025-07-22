module EsmMiotMonitor

class LineSolution < GXTModel

    include Mongoid::Document

    key :name, String
    key :webhook_url, String
    
end

class LineGroup < GXTModel

    include Mongoid::Document
    
    has_many :messages, :class_name=>'EsmMiotMonitor::LineMessage', foreign_key: 'account_id'
    
    key :name, String
    
    key :group_id, String
    
    key :type, String
    
    key :solution, String
    key :solution_id, ObjectId


    def send_message text, option={:type=>'text'}
  
  
      url = 'http://103.20.120.53:4556/send?channel=ems'
  
      url = Setting.get 'outgoing_webhook', url
  
      if self.group_id
        
       uri = URI(url)
       if option[:type] == 'text'
  
            res = Net::HTTP.post_form(uri, 'group_id' => self.group_id, 'text' => text)
  
        elsif option[:type] == 'raw'
          puts 'type=raw'+text+' group_id:'+self.group_id
            res = Net::HTTP.post_form(uri, 'group_id' => self.group_id, 'msg' => text)
  
        end
        puts res.body
        return res.body
    #   puts res.body
  
      end
  
    end
  

end

class LineAccount < GXTModel

    include Mongoid::Document
  
    has_many :messages, :class_name=>'EsmMiotMonitor::LineMessage', foreign_key: 'account_id'
  
    key :name, String
  
    key :user_id, String
  
    key :type, String
    
    key :solution, String
    key :solution_id, ObjectId

  
    def send_message text, option={:type=>'text'}
  
  
      url = 'http://103.20.120.53:4556/send?channel=ems'
  
      url = Setting.get 'outgoing_webhook', url
  
      if self.user_id
       uri = URI(url)
       if option[:type] == 'text'
  
            res = Net::HTTP.post_form(uri, 'user_id' => self.user_id, 'text' => text)
  
        elsif option[:type] == 'raw'
          puts 'type=raw'+text+' user_id:'+self.user_id
            res = Net::HTTP.post_form(uri, 'user_id' => self.user_id, 'msg' => text)
  
        end
        puts res.body
        return res.body
    #   puts res.body
  
      end
  
    end
  
  
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

    def acl
  
      return {:register=>'*',:image_upload=>'*', :register_remote=>'*', :provider=>'*'}
  
    end
  
  end
  
  class LineMessageController < GXTDocument
  
  end

  class LineSolutionController < GXTDocument
  
  end

  class LineGroupController < GXTDocument
  
  end

end