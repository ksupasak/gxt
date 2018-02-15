class Setting
  include MongoMapper::Document
  
  key :name, String
  key :value, String
end


class Device
  include MongoMapper::Document
  
  key :name, String
  key :params, String
  key :title, String
  key :type, String
end


class Adv
  include MongoMapper::Document
  key :name, String
  key :description, String
  key :url, String
  key :image_1, ObjectId
end

class Attachment
  include MongoMapper::Document
  key :title,String
  key :selected,Integer
  key :params,String
  key :ref,String
  key :filename,String
  key :path,String
  key :project_id,Integer
  key :ssid,String
  key :file_id,ObjectId
  key :thumb_id,ObjectId
end


class SettingController < GXTDocument

end

class AdvController < GXTDocument

end


class DeviceController < GXTDocument

end


class AttachmentController <GXT
  def content params
    att = Attachment.find params[:id]
    if att
     
      grid = Mongo::Grid.new(MongoMapper.database)

        file = nil
        content = nil
        @context.content_type 'image/png'

        if params[:thumb] 

          if att.thumb_id == nil or (file = grid.get(att.thumb_id) )== nil or params[:thumb]=='2'
               ofile = grid.get(att.file_id)
               ext = ofile.filename.split(".")[-1]
               ext = 'jpg'
               filename= ofile.filename
               fname = "tmp/cache/#{att.file_id}.#{ext}"
               rname = "tmp/cache/#{att.file_id}_thumb.#{ext}"
               f = File.open(fname,'w')
               f.write ofile.read.force_encoding('utf-8') 
               f.close
               size = '128x128'
               size = '256x256' if params[:thumb]=='2'
               puts `/usr/local/bin/convert -resize #{size} #{fname} #{rname}`
               file = File.open(rname,'r')
               content = file.read
               file.close
               File.delete fname
               File.delete rname
               id = grid.put(content,:filename=>filename)
               # puts "new id #{id}"
               att.update_attributes :thumb_id=>id
               file = grid.get(att.thumb_id)

         else
            content = file.read     
         end



        else
                file = grid.get(att.file_id)
                content = file.read
        end

     
     
        return content
     
    end
   
  end
end




