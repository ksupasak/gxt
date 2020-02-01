
module IACS
  
def self.get_val l, start
       if l.size >start+1
       a = l[start]
       b = l[start+1]
       
       x = 256*a+b
       x = -256*(256-a)+b if a>200
      return x
    else
      return nil
    end
end
def self.get_list l, start, len
  
    set = []
     # puts l[0..40].join(" ")
     len.times do |i|
       
       a = l[start+i*2]
       b = l[start+i*2+1]
       if a 
       x = 256*a+b
       x = -256*(256-a)+b if a>200
    

       set << x
        end
     end
     set
  
end

# 398 is device alert

def self.parser l
  if l.size > 0 
    debug = true
    debug = (l.size!=602 and l.size!=302 and l.size!=398 and l.size!=1298 and l.size!=252 and l.size!=110)  
  
  # puts 'size '+ l.size.to_s + " ========================================="
  
  ip = l[12..15]
  
  # puts ip.join(".")
  
  startup = 32
  
  map = {}
  wave_key = {}
  
  pos = startup
  tag = l[pos..pos+1].join
  
  # puts tag
  
  if false #or l.size == 110 #l.size == 252 #l.size == 398 or l.size == 1298
    
    n = 30 
    r = l.size/n+1
    
    print "-\t"
    
    n.times do |i|
       
      print "#{i}\t" 
    
    end
    puts 
    r.times do |j|
        
      print "#{j*n}\t"
      
      n.times do |i|
        
        # print ".#{l[j*n+i].chr}\t"
        
        print "#{l[j*n+i]}\t"
        
      
      end
      
      puts
      
      
    end
    
    
    
  end
  
  puts "start #{tag} #{pos}" if debug
  
  
 count = 600
  while pos < l.size and (tag = l[pos..pos+1].join ) and count > 0  # and tag!='03' and tag!= '016' and tag!='013'  
    key = nil
    len = nil
    res = ''
     puts 'cur '+tag + " pos "+pos.to_s if debug
    if tag == '012'
      len = 12
    elsif tag == '0200' # range 200 values 
       res = get_list  l, pos+14, 40
       key = l[pos+10..pos+11].join("-")
       wave_key[key] = 40
       len = 94
    elsif tag =='0100' # range 100 values 
       # spo2
       res = get_list  l, pos+14, 20
       key = l[pos+10..pos+11].join("-")
       wave_key[key] = 20
       len = 54
     elsif tag =='050'  # range 50 values 
       res = get_list  l, pos+14, 10
       key = l[pos+10..pos+11].join("-")
       wave_key[key] = 10
       len = 34
    elsif tag == '014'
      # puts 'Start'
       len = 12
    elsif tag == '00' or tag =='0120'    # normal key value
         res = get_val l, pos+30
         key =l[pos+14..pos+18].join("-")
         len = 36
    elsif tag == '018'
       len = 130
    elsif tag == '010'
        # hn bed
        len = 302
        
        
        s = []
        8.times do |i|
          break if l[i*2+97]==0
          s<<l[i*2+97].chr
        end
        map['bed'] = s.join.strip
        
        s = []
        40.times do |i|
          break if l[i*2+133]==0
          s<<l[i*2+133].chr
        end
        map['msg'] = s.join.strip
        
    elsif tag == '015'
        len = 252
    elsif tag == '024'
        len = 194
    elsif tag == '00'
      puts "Tag : #{tag} " 
    else
        #puts '========================================'
    end
    
   # puts "#{tag}\t#{pos}\t#{len}\t#{key}\t#{res}"
    
    if key
        map[key] = res
    end
    
    
    pos+=len if len
    
      count-=1
      
  end

end

# puts map.keys.join("\t")
if debug #or l.size==1298 
map.keys.sort.each do |i|
  puts "#{i}\t#{map[i]}" 
end 
end

puts "Last Pos : #{pos} from #{l.size} " if debug

map['wave_key'] = wave_key

  return map

end

end
