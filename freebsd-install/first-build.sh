#!/bin/sh

ln -s /root/freebsd_soekris/net5501/NET5501       /usr/src/sys/i386/conf/NET5501
ln -s /root/freebsd_soekris/net5501/NET5501.hints /usr/src/sys/i386/conf/NET5501.hints
ln -s /root/freebsd_soekris/net4521/NET4521       /usr/src/sys/i386/conf/NET4521
ln -s /root/freebsd_soekris/net4521/NET4521.hints /usr/src/sys/i386/conf/NET4521.hints

/bin/sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c /root/freebsd_soekris/net5501/net5501.cfg
/bin/sh /usr/src/tools/tools/nanobsd/nanobsd.sh -c /root/freebsd_soekris/net4521/net4521.cfg

mv /etc/rc.local /etc/rc.local.finished