require_relative 'error'

require 'socket'
require 'openssl'

module NetworkClipboard
  HANDSHAKE_STRING = "NetworkClipboard Handshake"

  class HandshakeException < NetworkClipboardError
  end

  class DisconnectedError < NetworkClipboardError
  end

  class AESConnection

    attr_reader :remote_client_id, :socket

    def initialize(config,socket)
      @socket = socket

      @encryptor = OpenSSL::Cipher::AES.new(128, :CBC)
      @encryptor.encrypt
      @encryptor.key = config.secret

      @decryptor = OpenSSL::Cipher::AES.new(128, :CBC)
      @decryptor.decrypt
      @decryptor.key = config.secret

      handshake(config.client_id)
    end

    def handshake(client_id)
      iv = @encryptor.random_iv
      @socket.send([iv.size].pack('N'),0)
      @socket.send(iv,0)
      iv_size = @socket.read(4).unpack('N')[0]
      @decryptor.iv = @socket.read(iv_size)

      # Verify it all worked.
      send(HANDSHAKE_STRING)
      raise HandshakeException unless receive == HANDSHAKE_STRING

      send(client_id)
      @remote_client_id = receive
    end

    def send(new_content)
      ciphertext = @encryptor.update(new_content) + @encryptor.final
      @socket.send([ciphertext.size].pack('N'),0)
      @socket.send(ciphertext,0)
      @encryptor.reset
    end

    def receive()
      size_bits = @socket.read(4)
      if size_bits.nil? and @socket.eof?
        raise DisconnectedError
      end
      ciphertext_size = size_bits.unpack('N')[0]
      ciphertext = @socket.read(ciphertext_size)
      plaintext = @decryptor.update(ciphertext) + @decryptor.final
      @decryptor.reset

      return plaintext
    end

    def close_read
      @socket.close_read
    end

    def close_write
      @socket.close_write
    end
  end
end
