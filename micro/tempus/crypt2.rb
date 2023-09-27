#!/usr/bin/env ruby
require "openssl"
require 'digest/sha2'
require 'base64'

# We use the AES 256 bit cipher-block chaining symetric encryption
alg = "AES-256-CBC"

# We want a 256 bit key symetric key based on some passphrase
# digest = Digest::SHA256.new
# passphase = "ems"+format('%010d', rand()*10000000000)
# puts passphase
#
# digest.update(passphase)
#
# key = digest.digest
# We could also have just created a random key
# key = OpenSSL::Cipher::Cipher.new(alg).random_key

# For security as part of the encryption algorithm, we create a random
# initialization vector.
# iv = OpenSSL::Cipher::Cipher.new(alg).random_iv



b64key = "nRHprq9d0Y9UefyxJ3buzZp0Do5RpFtacxzDyRK77VQ="
b64iv = "Nki18CKUFhH5CrI3TAaWdg=="

b64key = "Xltgk6zzpL9AIq2l8fi+Eau/Rhskcb69QoisJwj+6QA="
b64iv = "T5+TIqYU1pPgHDszsAQV6Q=="

b64key = "XP2uDwKggAPgfjtzE6UMGJkV0Ns4CKjQCEpgLP8tW3k="
b64iv = "wQxJmQJYh9zHCKR5L6Bk/Q=="

key = b64key.unpack('m')[0]
iv = b64iv.unpack('m')[0]

# Now we do the actual setup of the cipher
aes = OpenSSL::Cipher::Cipher.new(alg)
aes.encrypt
aes.key = key
aes.iv = iv


decode_cipher = OpenSSL::Cipher::Cipher.new(alg)
decode_cipher.decrypt
decode_cipher.key = key
decode_cipher.iv = iv

data = "A5yPKnq8yLJKwtxOnyfhACcsWVpUYUj63VbsDCTdy+D+GGa4rnJATz1bvnPCU+/8"
data = "gcbfEBUB3nQc+nCsjMknLiqmk+lbbF6l0Leuv+ZY+1I="
data = "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"
data = "PJIDytsw4SdM1Zqn1NyJ+9lDlzq/nJBeJ7ivnjutFzlEs500p+/cHVLagR45pUQoNu3arW+F7SG4FDB/a/EQG4F4b58ru0h08OfD1wNpSnKeBCpYDCUey5Eiw+uZwhQ7mIYy2cV7a2Ibn619wYdeKVPayOquAGsxsVXp/sgQtoF8fbgooWuOecMNdSuqFU62ZLYumwA4YW+yfbJvTR/vtnqsKyVCK7WPiRQmyu+bS/7cJDxGzhBn5LwSRNTrZS38qSIUFq+L7t2H9EDDQoDwTw=="



plain = decode_cipher.update(data.unpack('m')[0])
plain << decode_cipher.final
puts plain
#
# # Now we go ahead and encrypt our plain text.
# cipher = aes.update("This is line 1\n")
# cipher << aes.update("This is some other string without linebreak.")
# cipher << aes.update("This follows immediately after period.")
# cipher << aes.update("Same with this final sentence")
# cipher << aes.final
#
# puts "Our Encrypted data in base64"
# cipher64 = [cipher].pack('m')
# puts cipher64
#
#
#
# decode_cipher = OpenSSL::Cipher::Cipher.new(alg)
# decode_cipher.decrypt
# decode_cipher.key = key
# decode_cipher.iv = iv
# plain = decode_cipher.update(cipher64.unpack('m')[0])
# plain << decode_cipher.final
# puts "Decrypted Text"
# puts plain

# '
# # aes encode a file into another file.
# File.open("foo.enc","w") do |enc|
#    File.open("foo") do |f|
#      loop do
#        r = f.read(4096)
#        break unless r
#        cipher = aes.update(r)
#        enc << cipher
#      end
#    end
#    enc << aes.final
# end
# '