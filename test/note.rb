  grid = Mongo::Grid.new(MongoMapper.database)
id = grid.put(io.read,:filename=>filename)
# ============

 grid = Mongo::Grid.new(MongoMapper.database)
	  
  file = nil
  content = nil
  
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
  
  
  
 
  
  render :text=>content,:content_type=>file.content_type