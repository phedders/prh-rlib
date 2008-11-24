# This is a small library of "essential" routines

%w(
  openssl
).each {|r| require r}

def simple_decrypt(iv,crypted,password)
  crypt = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
  crypt.decrypt
  crypt.key = Digest::SHA256.digest(password)
  crypt.iv = iv
  data = crypt.update(crypted)
  data << crypt.final rescue nil
end

def simple_encrypt(iv,data,password)
  crypted = {}
  crypt = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
  crypt.encrypt
  crypt.key = Digest::SHA256.digest(password)
  crypt.iv = crypted[:iv] = iv ? iv : crypt.random_iv
  crypted[:data] = crypt.update(data)
  crypted[:data] << crypt.final
  return crypted
end

