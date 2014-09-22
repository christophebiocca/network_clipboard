Network Clipboard
=================

Synchronizes the clipboard of multiple machines on a network.
Uses AES-128-CBC with a pre-shared secret to protect your clipboard from the NSA (NSA-proofness not guaranteed).
The internal API is __not stable__. Please don't rely on it.

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

Once setup, all machines can join/leave the newtwork at will. The topology should adjust.

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

None right now, but please use github issues if you find any.
