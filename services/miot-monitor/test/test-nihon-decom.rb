
require "base64"
lines = File.open("out.txt").readlines

puts lines.size


for i in lines 
  t = i.split("|")
  for j in t
    
    k = j.split("^")
    
  if k[0] == 'HL7Gateway'
    
    puts k.inspect 
    
    
    content = k[4]
    
    out = File.open('out.mwf','w')
    out.write Base64.decode64(content)
    out.close
    
  end
  
end
end

