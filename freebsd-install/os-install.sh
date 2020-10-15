#!/bin/sh

DIST="http://ftp.freebsd.org/pub/FreeBSD/releases/i386/$(uname -r)"

# Global settings.
ME=installer
DISK="ada0"
MOUNT="/tmp/inst"

BOOT_SIZE=512K
SWAP_SIZE=512M

die() {
    gpart undo ${DISK} > /dev/null 2>&1
    exit 1
}

trap die

# resolv.conf from DHCP ends up in here, so make sure the directory exists
mkdir /tmp/bsdinstall_etc
dhclient em0

kldload /boot/kernel/geom_concat.ko

echo "Creating partitions"
dd if=/dev/zero of=/dev/${DISK} bs=1k count=1 || die
gpart create -f x -s gpt ${DISK} || die

# Add partitions.
gpart add -f x -t freebsd-boot -l gptboot0 -b 40 -s ${BOOT_SIZE} ${DISK} || die
gpart add -f x -t freebsd-swap -l gptswap0       -s ${SWAP_SIZE} ${DISK} || die
gpart add -f x -t freebsd-ufs  -l gptroot0                       ${DISK} || die

# Setup boot stuff.
gpart bootcode -f x -b /boot/pmbr -p /boot/gptboot -i 1 ${DISK} || die

# Commit gpart changes.
gpart commit ${DISK} || die

# Create growable filesystems.
gconcat label root /dev/gpt/gptroot0 || die

newfs -L rootfs -U -j         /dev/concat/root || die

swapon /dev/gpt/gptswap0 || die
mkdir -p "${MOUNT}" || die
mount /dev/ufs/rootfs "${MOUNT}" || die

echo "Fetching distributions"
fetch "${DIST}/base.txz"   -o - | tar --unlink -xpJf - -C "${MOUNT}" || die
fetch "${DIST}/kernel.txz" -o - | tar --unlink -xpJf - -C "${MOUNT}" || die
fetch "${DIST}/src.txz"    -o - | tar --unlink -xpJf - -C "${MOUNT}" || die

echo "Configuring system"
cat >> "${MOUNT}/boot/loader.conf" <<EOF || die
geom_concat_load="YES"
beastie_disable="YES"
autoboot_delay="-1"
EOF

cat >> "${MOUNT}/etc/fstab" <<EOF || die
/dev/gpt/gptswap0  none                swap       sw  0  0
/dev/ufs/rootfs    /                   ufs        rw  0  1
EOF

cat >> "${MOUNT}/etc/rc.conf" <<EOF || die
ifconfig_em0="DHCP"
hostname="soekris_build"
cron_enable="NO"
syslogd_flags="-ss"
vboxguest_enable="YES"
vboxservice_enable="YES"
sendmail_enable="NO"
sendmail_submit_enable="NO"
sendmail_outbound_enable="NO"
sendmail_msp_queue_enable="NO"
EOF

echo "Updating OS and installing packages"
cp /etc/resolv.conf "${MOUNT}/etc"
mount -t devfs devfs "${MOUNT}/dev"
chroot "${MOUNT}" /usr/bin/env -i TERM=$TERM /bin/csh <<EOF
env PAGER=cat freebsd-update --not-running-from-cron fetch
freebsd-update install
pkg install -y git virtualbox-ose-additions zip
cd /root
git clone https://github.com/unixgeek/freebsd_soekris.git
fetch https://github.com/unixgeek/freebsd_soekris/archive/net5501.zip
EOF

cp /root/first-build.sh "${MOUNT}/etc/rc.local"

umount "${MOUNT}/dev"
umount "${MOUNT}"

poweroff