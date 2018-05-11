paths = []

# paths << "/Volumes/Disk1/room10"
paths << "/Volumes/Disk1/room11"

for path in paths

list = Dir["#{path}/**/*.mov"]
puts path

map = {}
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
  cmd = "/usr/local/bin/ffmpeg -ss 00:00:00 -i '#{i}' -vframes 1 -q:v 2 #{capture_path}"
  `#{cmd}`
  puts "Capture track no : #{track_name} completed. #{capture_path}"
  
  else
  # puts "Capture track no : #{track_name} existed."
  end
  # rename to .mp4 to check video is processed.
  `mv '#{i}' #{File.join(folder,track_name+'.mp4')}`
  map[id] << a
  
  
end

# puts map.inspect

end

