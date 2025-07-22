require 'sinatra'

set :bind, '0.0.0.0'
set :height, '0.00'
set :weight, '0.00'


    get '/' do
      
       
      if Time.now.to_i%5==0
       
      settings.height = format('%.02f',(170+rand(200)/100.0)/100)
      settings.weight = format('%.02f',(70+rand(2000)/100.0))
      
      
      end
      
      
      weight = settings.weight
      height = settings.height
      
      
      
      current_weight = format('%.02f',(70+rand(2000)/100.0))
      
      
      html = <<HTML
      <!DOCTYPE html>
      <!-- saved from url=(0021)http://172.20.10.236/ -->
      <html lang="de">
      <head>
          <meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
          <title>Alibaba WebInterface</title>
      </head>
      <body>#{}
          <table>
              <tbody>
                  <tr>
                      <td>WebServer</td>
                      <td>Version 1.0</td>
                  </tr>
                  <tr>
                      <td>
                          <br>
                      </td>
                  </tr>
                  <tr>
                      <td>Name</td>
                      <td>01284136189533</td>
                  </tr>
                  <tr>
                      <td>Scale Model</td>
                      <td>seca 284</td>
                      <td>01284031207378</td>
                  </tr>
                  <tr>
                      <td>
                          <br>
                      </td>
                  </tr>
                  <tr>
                      <td>Current Weight</td>
                      <td>#{current_weight}</td>
                      <td>kg</td>
                  </tr>
                  <tr>
                      <td>Trig. Weight</td>
                      <td>#{weight}</td>
                      <td>kg</td>
                  </tr>
                  <tr>
                      <td>Height</td>
                      <td>#{height}</td>
                      <td>m</td>
                  </tr>
                  <tr>
                      <td>Scan Value</td>
                      <td></td>
                  </tr>
              </tbody>
          </table>
          <h3>CONFIG</h3>
          <form method="get">
              <p>
                  Login-Pwd 
                  <input type="password" name="LoginPwd" size="32" maxlength="59">
              </p>
              <p>
                  <input type="submit" value="Submit">
              </p>
          </form>
          <br>
          <br>
          Copyright © 2018 seca gmbh &amp; co. kg. All rights reserved.
      </body>
      </html>
HTML
  

html


    end