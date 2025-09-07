
require 'openssl'
require 'base64'

def generate_keys
  key = OpenSSL::PKey::RSA.new 2048
  public_key = key.public_key
  [key.to_pem, public_key.to_pem]
end

def encrypt(public_key_pem, plaintext)
  public_key = OpenSSL::PKey::RSA.new public_key_pem
  ciphertext = public_key.public_encrypt(plaintext)
  Base64.encode64(ciphertext)
end

def decrypt(private_key_pem, ciphertext_base64)
  private_key = OpenSSL::PKey::RSA.new private_key_pem
  ciphertext = Base64.decode64(ciphertext_base64)
  private_key.private_decrypt(ciphertext)
end

# Example Usage:
private_key_pem, public_key_pem = generate_keys

puts "--- Private Key ---"
puts private_key_pem
puts "\n--- Public Key ---"
puts public_key_pem

message = "This is a secret message that needs to be encrypted."
puts "\nOriginal Message: #{message}"

encrypted_message = encrypt(public_key_pem, message)
puts "Encrypted Message (Base64): #{encrypted_message}"

decrypted_message = decrypt(private_key_pem, encrypted_message)
puts "Decrypted Message: #{decrypted_message}"

# Verify if decryption was successful
if message == decrypted_message
  puts "\nEncryption and Decryption successful!"
else
  puts "\nError: Decrypted message does not match original."
end







require 'sinatra'

set :bind, '0.0.0.0'
set :port, 4444

get '/' do
  "Welcome to the RSA Encryption/Decryption Service!"
end

get '/generate_keys' do
  private_key_pem, public_key_pem = generate_keys
  content_type :json  , charset: 'utf-8'

  { private_key: private_key_pem, public_key: public_key_pem }.to_json
end

post '/encrypt' do
  public_key_pem = params[:public_key]
  plaintext = params[:plaintext]

  if public_key_pem.nil? || plaintext.nil?
    status 400
    return { error: "Missing public_key or plaintext parameters." }.to_json
  end

  begin
    encrypted_message = encrypt(public_key_pem, plaintext)
    content_type :json
    { encrypted_message: encrypted_message }.to_json
  rescue OpenSSL::PKey::RSAError => e
    status 400
    { error: "Invalid public key or encryption failed: #{e.message}" }.to_json
  end
end

post '/decrypt' do
  private_key_pem = params[:private_key]
  ciphertext_base64 = params[:ciphertext]

  if private_key_pem.nil? || ciphertext_base64.nil?
    status 400
    return { error: "Missing private_key or ciphertext parameters." }.to_json
  end

  begin
    decrypted_message = decrypt(private_key_pem, ciphertext_base64)
    content_type :json
    { decrypted_message: decrypted_message }.to_json
  rescue OpenSSL::PKey::RSAError => e
    status 400
    { error: "Invalid private key or decryption failed: #{e.message}" }.to_json
  rescue ArgumentError => e
    status 400
    { error: "Invalid Base64 encoding: #{e.message}" }.to_json
  end
end
