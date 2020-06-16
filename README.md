## FreeBSD Setup
* Install FreeBSD 8.4 (include src distribution)
* Run `freebsd-update`
* Set package site in `/root/.cshrc`:
    * `setenv  PACKAGESITE     ftp://ftp-archive.freebsd.org/pub/FreeBSD-Archive/old-releases/i386/8.4-RELEASE/packages/Latest/`
* Install pacakges:
    * `pkg_add -r sudo bash git`
* Create `build` user
* Add `build` user to sudo
* Login as `build` and clone this project
* Link kernel config:
    * `ln -s /home/build/freebsd_net4521/NET4521 /usr/src/sys/i386/conf/NET4521`
    * `ln -s /home/build/freebsd_net4521/NET4521.hints /usr/src/sys/i386/conf/NET4521.hints`

## Build Soekris Net4521 Image
1. `/bin/sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c /home/build/freebsd_net4521/net4521.cfg`
1. `ssh -o IdentitiesOnly=yes build@192.168.56.155 "cat /usr/obj/nanobsd.net4521/_.disk.full" | sudo dd of=/dev/sdc bs=1M`
