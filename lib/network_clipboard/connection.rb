require 'socket'
require 'openssl'

module NetworkClipboard
  HANDSHAKE_STRING = "NetworkClipboard Handshake"

  class HandshakeException < Exception
  end

  class AESConnection

    attr_reader :remote_client_id

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
      iv_size = @socket.recv(4).unpack('N')[0]
      @decryptor.iv = @socket.recv(iv_size)

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

    def receive(blocking=true)
      begin
        @partial_read ||= ''
        while @partial_read.size < 4
          @partial_read += @socket.recv_nonblock(4 - @partial_read.size)
        end
        while @partial_read.size < (total_size = 4 + @partial_read.unpack('N')[0])
          @partial_read += @socket.recv_nonblock(total_size - @partial_read.size)
        end
      rescue IO::WaitReadable
        if blocking
          IO.select([@socket])
          retry
        else
          return nil
        end
      end

      ciphertext,@partial_read = @partial_read.slice(4,@partial_read.size-4),nil

      plaintext = @decryptor.update(ciphertext) + @decryptor.final
      @decryptor.reset

      return plaintext
    end

    def close
      @socket.close
    end
  end
end
