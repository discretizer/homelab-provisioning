terraform {
  encryption {
     method "aes_gcm" "encrypt" {
      keys = key_provider.pbkdf2.passphrase_provider
    }

    state {
      method = method.aes_gcm.encrypt
      enforced = true
    }
  }
}