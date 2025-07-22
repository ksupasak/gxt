
class NihonDef
  
  attr_accessor :content 
  attr_accessor :l
  attr_accessor :p 
  attr_accessor :start
  attr_accessor :pointers
  
  def initialize file_name
    
    file = File.open(file_name,'r')

    @content = file.read
    @p = 0 
    @l = content.each_byte.to_a.collect{|i| i.to_i}
    
    @pointers = {}
    
  end
  
  def size
    
    return @l.size
    
  end
  
  def readb len
    
    j = 0
    
    k = 256**(len-1)
    len.times do |i|
      j+= l[@p+i]*k
      k/=256
    end
    
    @p+= len
    
    return j
    
  end
  
  def readc len
    
    buff = ""
    
    len.times do |i|
      # puts @l[i+@p]
      buff+= @l[i+@p].chr
    end
    @p+= len
    # puts
    return buff
    
  end
  
  
  def read_section 
      
      section_sum = readb(2)
      section_total = readb(4)
      section_id = readb(2)

      # puts "Section #{section_id}\t#{section_total}\t#{section_sum}"
    
      return {:sum=>section_sum, :total=> section_total, :id=> section_id}
  end
  
  
  
  def goto section_id, shift=nil
    if @pointers[section_id]
      @p = @pointers[section_id]+6
      return @p
    else
      return -1
    end
  end
  
  def pos
    return @p
  end
  

  def read_pointer_information_section
    
      @p = 6
    
      section = read_section
      

      byte_type = readb(1)
      kanji_type = readb(1)
      list_count = readb(2)
      # puts list_count
      
      list_count.times do |i|
        
        pointer = readb(4)
        section_id = readb(2)
        
        @pointers[section_id] = pointer
        
      end
      puts  @pointers.inspect 
      section.merge! :byte_type=>byte_type, :kanji_type=> kanji_type, :list_count=> list_count, :pointers=>@pointers
      
      return section 
       
  end
  

  def read_system_information_section
    
      
      goto 1
      section = read_section
    
      file_type = readc(4)
      system_type = readc(60).strip
      version = "#{readb(1)}.#{readb(1)}"
      location = readb(2)
      password = readc(10)
      manage_no = readb(4)
      
      inspect_code = readb(2)
      inspect_name = readc(8)
      
      section.merge! :file_type=>file_type, :system_type=>system_type, :version=>version, :location=>location, :manage_no=>manage_no,:inspect_code=>inspect_code, :inspect_name=>inspect_name
     
      return section
       
  end
  
  def read_general_wave_info_section
    
    goto 368
    section = read_section
    
    wave_length = readb(4)
    event_p = readb(4)
    wave_p = readb(4)
    14.times do |i|
      readb(4)
    end
    event_count = readb(4)
    
    event_list = []
    
    event_count.times do |i|
      
      event = {}
      
      event[:event_pos] = readb(4)
      event[:event_type] = readb(4)
      event[:event_detail] = readb(4)
      event[:string_length] = readb(2)
      event[:event_string] = readc(20)
      
      event_list << event
    end
    
    # puts event_list.inspect
    
    wave_count = readb(4)
    puts wave_count
    wave_list = []
    wave_count.times do |i|
      
      wave = {}
      
      wave[:wave_type] = readb(2)
      wave[:lead_code] = readb(2)
      wave[:sample_time] = readb(4)
      wave[:bit_precision] = readb(2)
      wave[:bit_precision_unit] = readb(2)
      wave[:bit_length] = readb(2)
      wave[:sample_count] = readb(4)
      wave[:compress_type] = readb(2)
      wave[:data_len] = readb(4)
      wave[:wave_data] = []
     
      # puts wave.inspect
      
      if wave[:wave_type] == 0 and wave[:lead_code] !=0
     
   
        bit_precision = wave[:bit_length]/8 
        (wave[:data_len]/bit_precision).times do |j|
        wave[:wave_data] << readb(bit_precision)
        end
              puts   wave[:wave_data][0..300]
         # puts wave[:wave_data].size
      elsif wave[:wave_type] == 1
        
        sample_count = wave[:sample_count]
        bit_length = wave[:bit_length]
         # puts sample_count
  #        puts bit_length
  #        puts sample_count * bit_length / 8
        (sample_count ).times do |j|
        wave[:wave_data] << readb(bit_length / 8)
        end
        # puts wave[:wave_data]].size
        
     elsif wave[:wave_type] == 2 or wave[:wave_type] == 3 or wave[:wave_type] == 4 or wave[:wave_type] == 5 or wave[:wave_type] == 6
        
        sample_count = wave[:sample_count]
        bit_length = wave[:bit_length]
         # puts sample_count
        #  puts bit_length
        #  puts sample_count * bit_length / 8
        (sample_count ).times do |j|
        wave[:wave_data] << readb(bit_length / 8)
        end
        
        # puts   wave[:wave_data]
        # puts wave[:wave_data].size
      
     end  
        # puts wave[:wave_data].size / 30.0
        
      wave_list << wave
        
    end
    
    puts wave_list.inspect
    
    
    
  end
  
  def get_lead_name code
    
    list = %{
      
      00 Blank
      01 I
      02 II
      03 V1(C1)
      04 V2(C2)
      05 V3(C3)
      06 V4(C4)
      07 V5(C5)
      08 V6(C6)
      09 V7(C X 1)
      0A V2R
      0B V3R
      0C V4R
      0D V5R
      0E V6R
      0F V7R
      10 X
      11 Y
      12 Z
      13 CC5
      14 CM5
      15 LA
      16 RA
      17 LL
      18 I
      19 E
      1A C
      1B A
      1C M
      1D F
      1E H
      3D III
      3E aVR
      3F aVL
      40 aVF
      41 -aVR
      42 V8(C x 2)
      43 V9(C x 3)
      44 V8R
      45 V9R
      64 ND
      65 NA
      66 NI
      67 NASA
      68 CM2
      69 ML
      6F 3LM
      70 3LH
      71 4LL
      72 4LM
      73 4LH
      74 APL
      75 APM
      76 APH
      77 EXT1
      78 EXT2
      79 EXT3
      7A EXT4
      7B EXT5
      7C EXT6
      80 Paddle/Pad
      81 Telemeter
      FE Don't display
    }
    
  end
  
  def read_general_measure_information_section
   
    goto 369
    section = read_section

    
    meas_cnt = readb(2)
    
    # puts "meas_cnt #{meas_cnt}"
    

      template = %{
        
        meas_type short
        date_time date_time
        data_pos ulong
        hrate short
        pulse_rate short
        resp_rate short
        spo2 short
        pressure_unit short
        etco2 short
        sys_bp short
        dia_bp short
        mean_bp short
        mea_bp date_time
        sys_ibp1 short
        dia_ibp1 short
        mean_ibp1 short
        sys_ibp2 short
        dia_ibp2 short
        mean_ibp2 short
        temperature_unit short
        temp1 short
        label_temp1 short
        temp2 short
        label_temp2 short
        st_1 short
        st_2 short 
        st_3 short
        vpc short
        cpr_depth short
        cpr_rate short
        length_unit short
        pr_press1 short
        pr_press2 short
        
        
        ecg1_lLead short
        ecg1_sense short
        ecg2_lLead short
        ecg2_sense short
        ecg3_lLead short
        ecg3_sense short
        label_press1 short
        label_press2 short
        hum_filter_sts short
        filter short
        
        anotation_ch short
        exec_mode short
        spo2_gain short
        escco_disp_param short
        param_escco1 short
        escco1 short
        param_escco2 short
        escco2 short 
        param_escco3 short 
        escco3 short
        param_escco4 short
        escco4 short
        param_escco5 short
        escco5 short
        param_escco6 short
        escco6 short
        param_escco7 short
        escco7 short
        
        amsa1x10_1 ushort
        amsa1x10_2 ushort
        amsa1x10_3 ushort
        amsa1x10_4 ushort
        amsa1x10_5 ushort
        amsa1x10_6 ushort
        amsa1x10_7 ushort
        amsa1x10_8 ushort
        amsa1x10_9 ushort
        amsa1x10_10 ushort
        
        amsa2x10_1 ushort
        amsa2x10_2 ushort
        amsa2x10_3 ushort
        amsa2x10_4 ushort
        amsa2x10_5 ushort
        amsa2x10_6 ushort
        amsa2x10_7 ushort
        amsa2x10_8 ushort
        amsa2x10_9 ushort
        amsa2x10_10 ushort
        
        etco2_unit short
        etco2_value short
}    
        
ts = template.split("\n").collect{|i| i.strip.split(" ") if i.strip.size>0 }.compact 

  vitals = []  

meas_cnt.times do |i|
      
  # puts "POS\t#{@p}"
  
  vital = {}
  
ts.each do |i| 

    key, type = i
    # puts "key #{key} #{type}"  
      value = nil
    
    case type
    when 'short'
      value = readb(2)
      value = nil if value == 32767
      value = nil if value == 32768
      
    when 'ushort'
      value = readb(2)
    when 'date_time'
      year = readb(2)
      month = readb(1)
      day = readb(1)
      hour = readb(1)
      minute = readb(1)
      second = readb(1)
      adjust_word_boundary = readb(1)
      
      value = format("%04d-%02d-%02dT%02d:%02d:%02d",year, month, day, hour, minute, second )
    when 'ulong'
      value = readb(4)
    
    else
      value = nil
    end
      
    vital[key.to_sym] = value 
    
end
      
   vitals << vital   
   78.times do |i|
     readb(1)
   end
   
    end
    
   
    
    section[:vitals] = vitals
    
    
    return section 
    
    
  end
  
end

#
#
# for i in files[0..0]
#
#
# data =   NihonDef.new(i)
#
# puts data.size
#
#
# file = File.open(i,'r')
#
# content = file.read
#
# # puts content[0..300].inspect #
#
#  l = content.each_byte.to_a.collect{|i| i.to_i}
#
#
# # extract header
# file_sum =  data.readb(2)
# file_total = data.readb(4)
#
# # puts "Header #{file_sum} #{file_total}"
#
#
#
#
# pointer_information_section = data.read_pointer_information_section
# puts pointer_information_section.inspect
#
# system_info_section = data.read_system_information_section
# puts system_info_section.inspect
#
# puts
#
#
# general_measure_info_section = data.read_general_measure_information_section
# puts general_measure_info_section.inspect
# puts
#
# for i in general_measure_info_section[:vitals]
#
#   puts i.inspect
#   puts
#
# end
# end
# general_wave_info_section = data.read_general_wave_info_section
# puts general_wave_info_section.inspect


# data.goto 2
# section = data.read_section
# puts section.inspect
#
# data.goto 256
# section = data.read_section
# puts section.inspect
#
# data.goto 368
# section = data.read_section
# puts section.inspect
#
# data.goto 369
# section = data.read_section
# puts section.inspect







# 200.times do |i|
#
# data.goto 2, i
# puts data.pos
#
# section = data.read_section
# # puts section.inspect
#
# end

# Pointer information section

# section header

# section = read_section(l,6)
# pointers = read_pointer_information(l,6)









# end 


