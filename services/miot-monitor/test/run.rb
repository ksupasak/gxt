

require 'net/http'


require 'socket'
puts "start"



# 
# puts HOST_NETWORK_BOARDCAST

puts "-- Start Vista120 S Service"

boardcast = Thread.new {
  
  msg_c = "~\x000\x02\x00\x00j\xF9\xE2\a\x04\a\x01\x05\f\x06CMS\x00\x00\x00\x00\x00HOSPITAL\x00\x00\x00\x00\x00\x00\x00\x00\b\x00\x00\x00\x0F\x00\x00\x00\x00\x00\x00\x00x\e\xDA\x03\xF0\x17\xDA\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x1C%\x00\x00\x00\x00\xC0\xA8d\v\xC0\xA8\x02\x9F\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
 
  msg_c =  "~\x000\x02\x00\x009g\xE3\a\a\t\x0E\x16:\x02CMS\x00\x00\x00\x00\x00DRAEGER\x00\x00\x00\x00\x00\x00\x00\x00\x00\a\x00\x00\x00\x0F\x00\x00\x00\x00\x00\x00\x00\xB0R\xA8\x00P\xA8\x91\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x1C%\x00\x00\x00\x00\xC0\xA8\x04x\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
 
  tip = '255.255.255.255'
  puts "Server Start UDP for Vista 120"
  socket = UDPSocket.open
  socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true) 
  
  loop do 
  # puts 'boast'
  socket.send msg_c, 0, tip, 9610
  # puts "Server UDP send "
  sleep 2
  end
  
}





	

		
    
	    $(document).ready(function(){

		
			var current_modal ;
			var will_reset_hn = true;
			var target_key = 'hn';
			var score_model = null;
		    var score_map = {};
		  





			$('#bp_start').click(function(){
				//alert('start')
				if(typeof device_interface === 'undefined'){
			
				}else{
					device_interface.bp_start();
				}
		
		
			})
			$('.btn-clear').click(function(){
				$(".display-hn").html('')
		        var myAudio = document.getElementById('audio-0')
		        myAudio.play();
			})
		
		    function checkInput(d){
				// alert(d)
		        v = $("."+d +" .v-entry").html().trim()
		        c = $("."+d +" .v-entry").closest(".sense-panel")
		        // prefix="de-"
		        // if(c.hasClass("d-entry-dark")) prefix="dk-"
		        if(v!==''&&v!=='-'){              
		            c.addClass("s-active").removeClass("s-empty")      
		        }else{
		            c.addClass("s-empty").removeClass("s-active")
		        }
		        isComplete = true

		        if(isComplete){
		            if($(".btn-entry").attr('class')){
						   $("#ready").click()
			
		                $(".btn-entry").addClass("btn-opd").removeClass("btn-entry")
		                $('.btn-opd').click(submitEntry)
         
		            }
		        }else{
		            $('.btn-opd').unbind()
		            $(".btn-opd").addClass("btn-entry").removeClass("btn-opd")

		        }
		    }
		
		    function submitEntry(){
	
	
	
				$('.btn-primary').html('Loading')
		        $.post( "post", prepare() , function( data ) {         
		            data.inspect 
		
					hn = $('.hn .v-entry').html().trim()
		
		            $("#beep").click()
		            setTimeout(function(){ window.location.replace("result?hn="+hn);  }, 1000);
               
		        });
		    }


		  
			function setup_sense(sn){
				
				
				// alert('setup ' +sn)
				
				s = score_map[sn]
				
			
				
				
				
				if(s!=null){
					
					$("#opdModal2 .opdModalTitle ").html(s['label'])
			     
					console.log("Setup score for : " + s['name'])
					
					the_modal = "opdModal2"
					$('.opdModal2-scale').hide();
					$('.opdModal2-op').hide();
					
					
					if(s['options']!=null&&s['options'].length>0){
						$('.opdModal2-options').empty()
						
						$('.opdModal2-op').show();	
						
						for(var id in s['options'] ){
							v = s['options'][id]
							
							$('.opdModal2-options').append('<tr><td><div class="btn-hn-option col" score="'+v['s']+'" map="'+v['k']+'" style="">'+v['v']+'</div></td></tr>');
							
						}
						
				        $(".btn-hn-option").on('click',function(){
				            var myAudio = document.getElementById('audio-'+cur_buffer)
				            myAudio.play();
							k = $(this).attr('map')
							$('.display-hn').html(k)
							$('#opdModal2 .save-modal').click();
							
				            return false;
				        })
	     				
					}
					
					if(s['scales']!=null&&s['scales'].length>0){
					// alert('scal')
						$('.opdModal2-scale').show();	
						
					}
					
					
				}else{
					
					d = $('.'+sn+" .v-entry").attr('label')
					
					$("#opdModal2 .opdModalTitle ").html(d)
					
					$('.opdModal2-scale').show();
					$('.opdModal2-op').hide();
					
				}
				
			}


		    function call_score(div_class, score_id, mode,data){
	   
		 	   // alert(score_id)
		 	   score_model = {};
			   
			   $('.act-score').removeClass("act-score")
			   $(".noti").html("")
			   
			   $(".noti").removeClass("score-warning-1")
			   
			   $(".noti").removeClass("score-warning-2")

			   $(".noti").removeClass("score-warning-3")
			   
	   
		 	   score_model['senses'] = [];
	   
		 	   $('.sense-container .sense-x').remove();
	   			
						   //
			   // s = {name:'rr',label:'RR',unit:'bpm'}
			   //
			   // 	   		   scores = []
			   // scores.push({min:null,max:-1,s:3,t:"Error"});
			   // scores.push({min:0,max:8,s:3,t:"very low"});
			   // scores.push({min:9,max:20,s:0,t:"low"});
			   // scores.push({min:21,max:25,s:1,t:"normal"});
			   // scores.push({min:26,max:35,s:2,t:"high"});
			   // scores.push({min:36,max:99,s:3,t:"very high"});
			   // scores.push({min:100,max:null,s:-1,t:"Error"});
			   //
			   // s['scales'] = scores
			   //
			   // 	   		   options = []
			   // options.push({k:'Tube',v:'Airtube',s:1,t:""});
			   // options.push({k:'Room',v:'RoomAir',s:0,t:""});
			   //
			   // 	   		   s['options'] = options
			   //
			   //
			   // 	   		   score_model['senses'].push(s);
			   // score_map[s['name']] = s;
			   //
			   //
			   // s = {name:'temp',label:'Temperature',unit:'C'}
			   //
			   // 	   		   scores = []
			   // scores.push({min:null,max:0,s:-1,t:"Error"});
			   // scores.push({min:0,max:35,s:2,t:"very low"});
			   // scores.push({min:35.1,max:36,s:1,t:"low"});
			   // scores.push({min:36.1,max:37.5,s:0,t:"normal"});
			   // scores.push({min:37.6,max:38.4,s:1,t:"high"});
			   // scores.push({min:38.5,max:99,s:2,t:"very high"});
			   // scores.push({min:100,max:null,s:-1,t:"Error"});
			   //
			   // s['scales'] = scores
			   //
			   //
			   //
			   // 	   		   score_model['senses'].push(s);
			   // 	   		   score_map[s['name']] = s;
			   //
			   //
			   // s = {name:'glucose',label:'Glucose',unit:'mg/L'}
			   //
			   // 	   		   scores = []
			   // scores.push({min:null,max:-1,s:3,t:"Error"});
			   // scores.push({min:0,max:8,s:3,t:"very low"});
			   // scores.push({min:9,max:20,s:3,t:"low"});
			   // scores.push({min:21,max:25,s:3,t:"normal"});
			   // scores.push({min:26,max:35,s:3,t:"high"});
			   // scores.push({min:36,max:99,s:3,t:"very high"});
			   // scores.push({min:100,max:null,s:-1,t:"Error"});
			   //
			   // s['scales'] = scores
			   //
			   // 	   		   score_model['senses'].push(s);
			   // score_map[s['name']] = s;
			   //
			   //
			   //
			   //
			   // s = {name:'bp_sys',label:'BP Sys',unit:'mg/L'}
			   //
			   // 	   		   scores = []
			   // scores.push({min:null,max:-1,s:3,t:"Error"});
			   // scores.push({min:0,max:8,s:3,t:"very low"});
			   // scores.push({min:9,max:20,s:3,t:"low"});
			   // scores.push({min:21,max:25,s:3,t:"normal"});
			   // scores.push({min:26,max:35,s:3,t:"high"});
			   // scores.push({min:36,max:99,s:3,t:"very high"});
			   // scores.push({min:100,max:null,s:-1,t:"Error"});
			   //
			   // s['scales'] = scores
			   //
			   // 	   		   score_model['senses'].push(s);
			   // score_map[s['name']] = s;
			   //
			   //
			   //
			   //
			   // s = {name:'concious',label:'Concious',unit:''}
			   //
			   // 	   		   options = []
			   // 	   		   options.push({k:'C01',v:'รู้สึกตัว',s:0,t:""});
			   // 	   		   options.push({k:'C02',v:'สับสน',s:1,t:""});
			   //
			   // 	   		   s['options'] = options
			   //
			   //
			   // 	   		   score_model['senses'].push(s);
			   // score_map[s['name']] = s;
			   //
			   //
			   
			   
			   
	    	$.ajax({
	   	   	  url: "get_score?score_id="+score_id,
	   	   	  context: document.body,
	   	   		method: 'get'
	   	   	}).done(function(data) {
				
	   	   		
				score_model = JSON.parse(data);
				// alert(score_model['name'])
				
				
				  console.log(score_model);
				
				
				
			   
			   
		 		 for(var si in score_model['senses']){
			   	
				
				
		 				s = score_model['senses'][si]
		 				score_map[s['name']] = s;
				
		 			   d = $('.'+s['name']+" .v-entry")
		 				   // alert(d.html())
		 				   if(d!=null&&d.html()!=undefined){
				   	
					
		 					console.log("Exist "+s['name'])
					   
					   
		 					$('.'+s['name']).addClass('act-score')   
					   
					   
					   
		 				   }else{
				   
				   	
				
				   	
				
		 		 	   x = s['name']
		 			   x_label = s['label']
			   
	   
	   
		 		 	   template = $('.sense-template').clone();
	   
		 		 	   template.removeClass('sense-template');
	   
		 		 	   template.find('.sense-title').html(x_label)
		 		 	   template.find('.sense').addClass(x)
		 		 	   template.find('.v-entry').attr('name',x)
		 	           template.find('.v-entry').attr('label',x_label)
	   
		 		 	   template.show();
	   
		 		 	   template.appendTo('.sense-container .no-gutters')
	   
	
		 
		   		     template.find(".v-entry").click(function(){
		   		         v = $(this).html().trim()
		   		 		console.log(v)
		   		         if(v=='-')v = '' 
		   		 		$(".display-hn").html(v)

		   		 		 current_modal = $(this).attr('name')
		   		 		 target_key = current_modal
	         
			 
		   		         setup_sense(current_modal)
		   				 $("#opdModal2").modal('toggle')
				 
				 
				 
		   		     })
			    
		 				template.find('.sense').addClass("act-score");
			 
			 
		 			    }
			 
			 
		
		 	   			}
			 
   		   
			 
						sos();
			
	   	   	});
			   
			   
			   
			   
			   
			 
		
	
	
		    }
	

		
	
			function getPatient(){
			    hn = $(".hn-value").html().trim()
	 
				console.log(hn)
				$.ajax({
				  url: "find_patient?hn="+hn,
				  context: document.body
				}).done(function(data) {
		  
				   patient = JSON.parse(data)
					console.log(patient)
			
					patient_name = "ไม่พบข้อมูล"
					if(patient['first_name']&&patient['first_name'].length>0){
				
						patient_name = patient['prefix_name']+patient['first_name']+" "+patient['last_name']
		
						$('.patient_name').html(patient_name)	
						$('.patient_gender').html(patient['gender'])	
						age = parseFloat(patient['age'])
						$('.patient_age').html(parseInt(age))	
						$('.hn .v-entry').html(patient['hn'])	
				
						will_reset_hn = true
			     
				
					}else{
						$('.patient_name').html(patient_name)	
						$('.patient_gender').html('-')	
						$('.patient_age').html('-')	
					}
				
				
		
			
			
					$('#ready').click()
			
			
				  // $( this ).addClass( "done" );
				}); 
	   
			}
		
		
		
		
	        function hnPush(s){
	            v = $(".display-hn").html().trim()
	            b = s.html()
	            if(b.indexOf("img")!==-1){
	                v = v.substr(0,v.length-1)
	    …





server = TCPServer.new  9600



puts 'start to accept'
 while true
 Thread.fork(server.accept) do |client|
   
   cms = TCPSocket.new '202.114.4.119', 9600
   
     puts
      puts 'monitor connected'
      puts client
      puts client.peeraddr.inspect
      
   line = "-"
   
    monitor_thread = Thread.new {
     while line.size!=0
   
     line = client.recv(40960)
     
     puts "#{Time.now.to_i}\t#{line.size}\tmonitor"#+line.inspect
    
     res = ""
              
              if line.size==13
                
              puts line.inspect
              
              cms.write line
              cms.flush
                
              res = "\xF8\x8F\x02\r\x00\xA4\xA5\xA5\xA5\xA4\xA5\xA1\xED" 
             
              client.write res
              client.flush
              
              res = "\xF8\x8F\x03\x98\x00\xA7\xA5\xA5\xA5)\xA5\x95$,\xA7$$\xA5l\xA1a\xB1\x90+\x7F\x8F\xDB+>M\xDA\If|X0\xB2\xF5\x97\xD0[\xA8\x86!\xF06\\\x85N\x9C\x82Z>\xD5\xF9\xDB\x1D\x9C\xA4v\xFE\x9E\x14\xF8+n\x19\x86\xE7\xBF\xAB\xC5\x15\xA2|R`\xD7K\x96\\\xE5s\xC5\xB2ux\xA6\xDA\xB5qg\x81\x94\xF9\x8B6\xEF\xA8{\xB5Z\xC6\x83\x89D3VS\x93\x86\xC5\x94\x9D\r\xCEn\t(\xCF\x04c\x06\xBEM\xE2?\x97\x94\x94\x86\xD0\xBC?\x12\xDFn\xB3)\xF4\xDB^\x06\x1C&\xA7\xA6\xA4\xA5\xA4\x15" 
          
               client.write res
               client.flush
              
             end
             
               
               if line.size==140
                 
                 
                 res= "\xF8\x8F\x04<\x00\xA6\xA5\xA5\xA5\x85\xA5l\x8A\xD5\xA1k.\t\a\xC3\x96\xA19\xFBK@\x1D\xC0\xC2\xBF\x008*\f@\xCF\xF4*\xD79\x93\n\xB2>/\x10\xCE\x03|\xBE<\x11\xAEF\x84\xF6\xCF\x12u\xBB"
                   client.write res
                   client.flush
                 
                 
               end
              
               if line.size==60
          
          
                  res= "\xF8\x8F\x05<\x00\xA1\xA5\xA5\xA5\x85\xA5\xE9\x86\xE2\x96\xB7$$\xF6\xCD\xD6\x89\xFB\xCA\xAC\xD5/\x98\xA1\x8F\x9AV\xB7L.\xA4\xD8.\xFA 9\x93\x03\xC2U\a\x8C\xAE\xAF\xCF\x1D@?$7\xCB]U\x1D\x1E"
                    client.write res
                    client.flush
          
          
                    res= "\xF8\x8F\x06,\x00\xA0\xA5\xA5\xA5\xB5\xA57uH\x11\xC0\xEF\x99Dl\xDEN!\x03c\xC7\xEE\x87\x89^M\xB9~\x14\xA4L\v\xAD\xF5U1\x93\xC8u\xF8\x8F\x06\x1C\x00\xA3\xA5\xA5\xA5\xAC\xA5:\x06aN\x9E\xA3&\&\x8E\x14\"\x12rKS\xF0"
                      client.write res
                      client.flush
          
                end
     
     
     # cms.write line
     # cms.flush
     
     end
     
   }
   
    cms_thread = Thread.new {
      line="-"
            while line.size>0
       
            line = cms.recv(40960)
            
            puts "#{Time.now.to_i}\t#{line.size}\tcms\t"+line.inspect
       
            client.write line
             client.flush
       
       
            end
       
          }
          
       monitor_thread.join()
    
     
     
    #  line2 = client.recv(40960)
    # puts "monitor send 2: "+line2.inspect
         #  
         #     
         # cms = TCPSocket.new '192.168.4.120', 9600
         # 
         # cms.write line
         #      cms.flush
             
         # line = cms.recv(40960)
         # puts "cms receive : "+line.inspect
         
         # cms.close
         
         
         # 
         # 
         # client.write line
         #    client.flush  
         # 
         # puts 'ok'
        #     
      # end
        #  token = "\xF8\x8F\x02\r\x00\xA4\xA5\xA5\xA5\xA4\xA5\xA1\xED"
        # # client_send  = "\xF8\x8F\x01\r\x00\xA4\xA5\xA5\xA5\xA4\xA5\xA1\xEE"
        #     
        #   
        #     line2 = client.recv(40960)
        #    puts line2.inspect
        #   
        
 end
  end
boardcast.join

sleep(1000)

# puts "connect"
# client_send  = "\xF8\x8F\x01\r\x00\xA4\xA5\xA5\xA5\xA4\xA5\xA1\xEE"
# s.write client_send
# s.flush 
# 
# line = s.recv(40960)
# server_send_back ="\xF8\x8F\x02\r\x00\xA4\xA5\xA5\xA5\xA4\xA5\xA1\xED"
# 
# puts line.inspect 


# while line = s.gets # Read lines from socket
#   puts line         # and print them
# end

cms.close
