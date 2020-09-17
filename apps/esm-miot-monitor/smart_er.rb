
module EsmMiotMonitor
  
    class SmartERController < GXT
    
      def acl
    
        return {:upload=>'*',:dashboard=>'*'}
    
      end
      
      def upload params
        
        switch @context.settings.name
        
        admit = Admit.find params[:admit_id]
        
        content = params[:capture]['tempfile'].read
       
       filename = params[:capture]['filename']
       
        connection =  Mongo::Client.new Mongoid::Config.clients["default"]['hosts'], :database=>Mongoid::Threaded.database_override
       
        grid = Mongo::Grid::FSBucket.new(connection.database)
        
        fid = grid.upload_from_stream(filename,content)
        

        meta = {}
        meta['sender'] = 'NA'
        meta['recipient'] = 'NA'
        meta['recipient_type'] = 'NA'
        meta['filename'] = filename
        meta['ts'] = Time.now.to_i
        meta['type'] = 'image'
        meta['media_type'] = 'image'
        
        station_id = nil
        
        i = meta
        
        begin 
         
        msg = Message.create :admit_id=> admit.id, :sender=> i['sender'], :recipient=> i['recipient'], :recipient_type=> i['recipient_type'], :content=> i['filename'], :ts=> i['ts'], :type=>i['type'], :media_type=>i['type'], :file_id=>fid, :station_id=>station_id
        
        puts params.inspect 
        
      rescue =>error
        error.backtrace 
      end
        
        
        return 'ok'
        
      end
    
    end
    
    
end