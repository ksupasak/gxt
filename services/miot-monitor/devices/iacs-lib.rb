
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

def self.parser l
  if l.size > 0 
 #  puts 'size '+ l.size.to_s
  
  ip = l[12..15]
  
  #puts ip.join(".")
  
  startup = 32
  
  map = {}
  wave_key = {}
  
  pos = startup
  tag = l[pos..pos+1].join
  #puts tag
  
 count = 600
  while pos < l.size and (tag = l[pos..pos+1].join )  and tag!='03' and tag!= '016' and tag!='013'  and count > 0 
    key = nil
    len = nil
    res = ''
    #puts tag
    if tag == '012'
      len = 12
    elsif tag == '0200'
       res = get_list  l, pos+14, 40
       key = l[pos+10..pos+11].join("-")
       wave_key[key] = 40
       len = 94
    elsif tag =='0100'
       # spo2
       res = get_list  l, pos+14, 20
       key = l[pos+10..pos+11].join("-")
       wave_key[key] = 20
       len = 54
     elsif tag =='050'
       res = get_list  l, pos+14, 10
       key = l[pos+10..pos+11].join("-")
       wave_key[key] = 10
       len = 34
    elsif tag == '014'
       len = 12
    elsif tag == '00'
         res = get_val l, pos+30
         key =l[pos+14..pos+18].join("-")
       len = 36
    elsif tag == '018'
       len = 130
    elsif tag == '010'
        # hn bed
        len = 128
    elsif tag == '024'
        len = 194
    else
        #puts '========================================'
    end
    
   #  puts "#{tag}\t#{pos}\t#{len}\t#{key}\t#{res}"
    
    if key
        map[key] = res
    end
    
    
    pos+=len if len
    
      count-=1
      
  end

end

map['wave_key'] = wave_key

  return map

end

end
