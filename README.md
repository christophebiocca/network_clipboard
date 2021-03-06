Network Clipboard
=================

Synchronizes the clipboard of multiple machines on a network.
Uses AES-128-CBC with a pre-shared secret to protect your clipboard from the NSA (NSA-proofness not guaranteed).

The internal API is __not stable__. Please don't rely on it.

Until this app reaches 1.0.0, client compatibility may break arbitrarily. Try to keep all your clients on the same version.

Install
-------

`gem install network_clipboard`

or if you want to be really safe

1. `gem cert --add <(curl -Ls https://raw.github.com/christophebiocca/network_clipboard/master/certs/christophebiocca.pem)`
2. `gem install network_clipboard -P MediumSecurity`

Which will protect you if rubygems hosting is tampered with.

Setup
-----

1. Run `network_clipboard` on any of your machines.
2. Copy the `.networkclipboard.secret` file to all other machines you want to share to.
3. Run `network_clipboard` on them too.
4. Enjoy your shared clipboard.

Usage
-----

Once setup, all machines can join/leave the network at will. The topology should adjust.

Supported Platforms
-------------------

Tested on Arch Linux and OSX, but should work on any os supported by the `clipboard` gem.

Should work on any ruby >= 1.9

TODO
----

- Figure out if there's a way not to write to the linux middle-mouse button clipboard.
- Test on Windows.
- Test on more complicated networks.
- Test with more than 2 computers.
- Add Perfect Forward Secrecy.
- Add per-peer auth (instead of shared secret).
- Allow temporary connections.
- Get someone else to look at the crypto bits and make sure they work.
- Use a garden variety service discovery (DNSSD?), if I can find bindings that work cross platform.
- Mobile App? Maybe?

Known Bugs
----------

See [github issues](https://github.com/christophebiocca/network_clipboard/issues).

License / Legal
---------------

Copyright 2014 Christophe Biocca

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
