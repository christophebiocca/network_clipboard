# lib/network_clipboard/authentication.rb
#
# Copyright 2014 Christophe Biocca
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'digest'

module NetworkClipboard
  class SharedSecretAuthentication
    def initialize(config)
      @secret = config.secret
    end

    def sign(bytes)
      Digest::HMAC.digest(@secret,bytes,Digest::SHA256)
    end

    def verify(bytes,signature)
      # Implements constant time compare.
      expected = sign(bytes)
      sigints,expints = [signature,expected].collect{|s| s.split.collect(&:ord)}
      compares = sigints.zip(expints).collect{|s,e| (s.nil? or e.nil?) ? 1 : s^e}
      compares.inject(&:|) == 0
    end
  end
end
