⚠️ This is not a drop-in replacement for `ip_vs_mh` as it appears in
Linux 4.18. See below.

# Consistent source hashing scheduler for Linux IPVS

This module is a backport of `ip_vs_mh` which will be integrated in
Linux 4.18. I am not the author of this module (Inju Song is) but I am
the sole perpetrator of the added bugs.

Based on [Google's Maglev algorithm][1], this scheduler builds a
lookup table in a way disruption is minimized when a change
occurs. This helps in case of active/active setup without
synchronization. Like for classic source hashing, this lookup table is
used to assign connections to a real server.

[1]: https://research.google.com/pubs/pub44824.html

## Differences with the upstream module

There are several differences with the real `ip_vs_mh` to be included
in Linux 4.18:

 1. TCP/UDP ports are always used for hashing. In my opinion, this
    should be the default. An opt-out would be nice, but I didn't add
    one.

 2. Backends with a weight of 0 are ignored (see below).

 3. Ability to fallback to another backend has been removed.

About the two last items, in my opinion, use of fallback is not
described in the Maglev paper and is an hybrid approach mixing the
"classic" way of doing consistent hashing. This is not needed here as
the original algorithm ensure the relative stability of the existing
positions in the lookup table when removing a server. Using a weight
of 0 is still useful to avoid updating the whole list while keeping
positions intact. However, ability to reschedule a connection when a
server becomes overloaded (with thresholds, at the cost of adding
local state) is lost. If there is really a use for this, I could add
back the fallback option.

For compatibility with the module in Linux 4.18, I would encourage you
to not use real servers with a weight of 0 since the behaviour is
different. Instead, remove the server from the list of servers when it
is unavailable. To add it back to the same position, it is possible to
send back the complete list of servers. Alternatively, you can
continue to use this backport: it works with Linux 4.18+ too.

## Compilation

This is an out-of-tree module. Just type `make` and you should get an
`ip_vs_mh.ko` file. You can use `insmod` to load it. If your kernel
source are in a non-standard place, use `make KDIR=...`.

There is no option to this scheduler. You can use it by its name:

    ipvsadm -A -t 203.0.113.15:80 -s mh
    ipvsadm -a -t 203.0.113.15:80 -r 10.234.79.11:80 -m
    ipvsadm -a -t 203.0.113.15:80 -r 10.234.79.12:80 -m
    ipvsadm -a -t 203.0.113.15:80 -r 10.234.79.13:80 -m -w 2

This module currently requires at least Linux 4.11.
