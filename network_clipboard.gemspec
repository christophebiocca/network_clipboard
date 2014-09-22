Gem::Specification.new do |s|
  s.name        = 'network_clipboard'
  s.version     = '0.0.0'
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
end