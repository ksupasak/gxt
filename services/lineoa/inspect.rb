require 'sinatra'

#use Rack::Protection::HostAuthorization, whitelist: ['localhost', '127.0.0.1', '147.92.150.194']
set :protection, except: :http_origin  # or disable only HostHeader check
disable :protection                     # or completely disable Rack::Protection (less secure)
# Log every request
before do
  puts "=== Incoming Request ==="
  puts "#{request.request_method} #{request.url}"
  puts "Headers:"
  request.env.select { |k,v| k.start_with? 'HTTP_' }.each do |key, value|
    puts "  #{key.gsub(/^HTTP_/, '').split('_').map(&:capitalize).join('-')}: #{value}"
  end

  puts "Params:"
  puts params.inspect

  request.body.rewind
  body_content = request.body.read
  puts "Body:"
  puts body_content
  puts "========================"
end

# Respond to any route
any_method = %w[get post put patch delete options]
any_method.each do |m|
  send(m, '/*') do
    "Request received: #{request.request_method} #{request.path}"
  end
end
