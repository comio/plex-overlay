Plex Overlay
============

This overlay contains Plex related ebuilds

Installation
------------

The easiest way to add this overlay to your Portage tree is through eselect repository.

```
# eselect repository add plex-overlay git https://github.com/comio/plex-overlay
```

If you prefer to use the legacy layman utility
```
# layman -a plex-overlay
```
#

Packages
--------


### Multimedia

#### Plex [media-tv/plex-media-server, media-tv/plex-media-player, media-tv/tautulli]
[Plex](http://plex.tv/) is a service that allows convenient access to central media over a variety of devices. Plex Media Player is a new desktop client for Plex that includes a nice ten-foot interface and is designed for connecting to the television. Note: Plex Pass users can add the "~amd64" or "~x86" keywords to the packages to get the latest Plex Pass versions.

Special Thanks
--------------

I would like to thank Foster McLane for her overlay (https://github.com/fkmclane/overlay) that has been the starting point for this work.
