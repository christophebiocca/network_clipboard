# network_clipboard.gemspec
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

Gem::Specification.new do |s|
  s.name        = 'network_clipboard'
  s.version     = '0.0.1'
  s.date        = '2014-05-21'
  s.summary     = "Network Clipboard Sharing"
  s.description = <<-DESC
Allows sharing of clipboard between multiple machines on the same network.
Encrypted using AES-128-CBC, relies on pre-shared secret file.
Internal API not stable yet. Only use the executable.
DESC
  s.authors     = ["Christophe Biocca"]
  s.email       = 'christophe.biocca@gmail.com'
  s.files       = Dir.glob('bin/*') + Dir.glob('lib/**/*.rb')
  s.bindir      = 'bin'
  s.executables = ['network_clipboard']
  s.homepage    = 'http://github.com/christophebiocca/network_clipboard'
  s.license     = 'Apache-2.0'
  s.add_runtime_dependency 'clipboard', '~> 1.0'
  s.cert_chain  = ['certs/christophebiocca.pem']
  s.signing_key = File.expand_path("~/keys/gem-private_key.pem")
end
