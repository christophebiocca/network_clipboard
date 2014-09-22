Network Clipboard
=================

Synchronizes the clipboard of multiple machines on a network.
Uses AES-128-CBC with a pre-shared secret to protect your clipboard from the NSA (NSA-proofness not guaranteed).
The internal API is __not stable__. Please don't rely on it.

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

- Go either full-blocking (with threads) or full-async, not the current godawful hybrid.
- Figure out if there's a way not to write to the linux middle-mouse button clipboard.
- Test on Windows.
- Test on more complicated networks.
- Test with more than 2 computers.
- Add Perfect Forward Secrecy.
- Add per-peer auth (instead of shared secret).
- Allow temporary connections.
- Get someone else to look at the crypto bits and make sure they work.
- Use a garden variety service discovery (DNSSD?), if I can find bindings that work cross platform.