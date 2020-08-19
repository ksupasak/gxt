module EsmMediaStreamIndex
  
def media_indexing paths
  
# paths = []

# paths << "/Volumes/Disk1/room10"
# paths << "/Volumes/Disk1/room11"

map = {}


for pathall in paths
path = pathall[0]
content_path = pathall[1]
list = Dir["#{path}/**/*.mov"]
puts path

for i in list
  
  t = i[path.size+1..-1].split("/")
  folder = i.split("/")[0..-2].join("/")
  
  
  key = t[4].split("-").join("/")
  op  = t[5]
  id = t[6]
  name = t[-1]
  
  map[id] = [] unless map[id]

  map_size = map[id].size
  
  track_name = "vdo-#{map_size}"
  
  a = {:solution=>t[2],:key=>key,:op=>op,:id=>id,:name=>name,:track=>track_name, :path=>i, :raw_size=> File.size(i)}
  capture_path = File.join(folder,track_name+'.jpg')
  
  
  unless File.exist?(capture_path)
  cmd = "ffmpeg -ss 00:00:00 -i '#{i}' -vframes 1 -q:v 2 #{capture_path}"
  `#{cmd}`
  puts "Capture track no : #{track_name} completed. #{capture_path}"
  
  else
  # puts "Capture track no : #{track_name} existed."
  end
  # rename to .mp4 to check video is processed.
  `mv '#{i}' #{File.join(folder,track_name+'.mp4')}`
  map[id] << a
  
  
end


end

#============


map = {}


for pathall in paths
path = pathall[0]
content_path = pathall[1]

list = Dir["#{path}/**/*.mp4"]
puts path

for i in list
  
  t = i[path.size+1..-1].split("/")
  folder = i.split("/")[0..-2].join("/")
  
  
  key = t[4].split("-").join("/")
  op  = t[5]
  id = t[6]
  name = t[-1]
  
  map[id] = [] unless map[id]

  map_size = map[id].size
  
  track_name = "vdo-#{map_size}"
  
  pathx = i[content_path.size+1..-1]
  
  a = {:solution=>t[2],:key=>key,:op=>op,:id=>id,:name=>name,:track=>track_name, :file_path=>i, :path=>pathx, :raw_size=> File.size(i)}
 
 
  map[id] << a
  
  
end


end



return map

end

end
