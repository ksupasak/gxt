
file = File.open("ECG01.mwf")

class BinaryReader

  attr_accessor :pointer, :content

  def initialize content
    puts 'init'
    @content = content
    @pointer = 0 
    
  end

  def read size=1
    
    data = @content[@pointer...@pointer+size].bytes.each {|i| i.to_s(16)}
    
    puts data.join("\t") 
    
    @pointer += size
    
  end
  
  def is_end 
  
    return @pointer < @content.size
    
  end

end


content = file.read

a = BinaryReader.new content

puts content.size

while a.is_end
  
a.read 6

end

